#include <unistd.h>

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <string_view>
#include <utility>

#include "define.h"
#include "base/log.h"
#include "base/local_udp_socket.h"
#include "base/util.h"
#include "zsh_complete_server/history_data.h"
#include "zsh_complete/version.h"
#include "zsh_complete/message.h"

constexpr const char* kTag = "zsh_server";

static std::ofstream log_file;
static bool is_test = false;

void log_callback(const std::string& log) {
  if (log_file) {
    log_file << util::GetTimeNow("%Y-%m-%d %H:%M:%S") << " " << log
             << std::endl;
  }
  if (is_test) {
    std::cerr << util::GetTimeNow("%Y-%m-%d %H:%M:%S") << " " << log
              << std::endl;
  }
}

void flush_callback() {
  if (log_file) {
    log_file.flush();
  }
}

std::pair<int, int> findSpace(std::string_view str) {
  int space1 = str.find(' ');
  if (space1 == std::string_view::npos) {
    return {-1, -1};
  }
  int space2 = str.find(' ', space1 + 1);
  if (space2 == std::string_view::npos) {
    return {space1, -1};
  }
  return {space1, space2};
}

static char sg_buffer[BUFFER_MAX_SIZE];
int main(int argc, char* argv[]) {
  if (argc > 1) {
    std::string arg = argv[1];
    if (arg == "--test") {
      is_test = true;
    }
  }
  LOG_I(kTag) << "================= zsh_server start =============== is_test: " << is_test;
  LogStream::SetLogLevel(LogLevel::kInfo);
#ifdef NDEBUG
  LogStream::SetLogCallBack({log_callback, flush_callback});
#endif
  std::string log_file_path = GetLogFile();
  if (log_file_path.empty()) {
    LOG_E(kTag) << "Get log file path failed";
    return 1;
  }
  log_file.open(log_file_path, std::ios::app);

  // Get server socket path
  std::string server_socket_path = GetSocketServerBaseName();
  if (server_socket_path.empty()) {
    LOG_E(kTag) << "Get socket server base name failed";
    return 1;
  }
  LOG_I(kTag) << "Server socket path: " << server_socket_path;

  // Create UDP socket server (blocking mode)
  LocalUdpSocket server(server_socket_path, false);
  if (server.Open() < 0) {
    LOG_E(kTag) << "Failed to open server socket";
    return 1;
  }
  LOG_I(kTag) << "Server socket opened successfully";

  std::string history_file = GetHistoryFile();
  if (history_file.empty()) {
    LOG_E(kTag) << "Get history file path failed";
    return 1;
  }
  LOG_I(kTag) << "History file: " << history_file;
  char buffer[BUFFER_MAX_SIZE];
  HistoryDataConfig config(HISTORY_MAX_SIZE, HISTORY_MAX_TERMINAL_SIZE);
  config.sleep_interval_seconds = HISTORY_SLEEP_INTERVAL_SECONDS;
  config.force_write_file_seconds = HISTORY_FORCE_WRITE_FILE_SECONDS;
  config.history_data_file = history_file;
  config.history_process_dead_seconds = HISTORY_PROCESS_DEAD_SECONDS;
  if (!config.Check()) {
    LOG_E(kTag) << "Invalid config: " << config.ToString();
    return 1;
  }
  LOG_I(kTag) << "Config: " << config.ToString();
  LOG_I(kTag) << "VERSION: " << COMPLETE_SERVER_VERSION;

  HistoryData data(config);
  int failed_count = 0;
  while (!is_test && true) {
    // Receive message from client using sg_buffer
    struct sockaddr_un client_addr;
    const int bytes_read = server.RecvFrom(sg_buffer, BUFFER_MAX_SIZE, &client_addr);
    if (bytes_read <= 0) {
      if (bytes_read < 0) {
        LOG_E(kTag) << "RecvFrom failed";
      }
      std::this_thread::sleep_for(std::chrono::milliseconds(200));
      continue;
    }

    // Parse ClientMessage
    if (bytes_read < static_cast<int>(sizeof(ClientMessage))) {
      LOG_E(kTag) << "Invalid message size: " << bytes_read;
      continue;
    }

    ClientMessage* client_msg = reinterpret_cast<ClientMessage*>(sg_buffer);
    int8_t command = client_msg->command;
    int32_t seq = client_msg->seq;
    int32_t pid = client_msg->pid;
    int32_t value_size = client_msg->value_size;

    // Validate message
    if (bytes_read != static_cast<int>(sizeof(ClientMessage) + value_size)) {
      LOG_E(kTag) << "Message size mismatch: expected "
                  << (sizeof(ClientMessage) + value_size)
                  << ", got " << bytes_read;
      continue;
    }

    // Copy value to string (since we'll reuse sg_buffer for response)
    std::string value(client_msg->value, value_size);

#ifndef NDEBUG
    LOG_I(kTag) << "Received: command=" << static_cast<int>(command)
                << " seq=" << seq << " pid=" << pid
                << " value_size=" << value_size
                << " value=" << value;
#endif

    // Handle EXIT command
    if (command == COMMAND_EXIT) {
      break;
    }

    // Handle TERMINAL_EXIT command
    if (command == COMMAND_TERMINAL_EXIT) {
      data.Exit(pid);
      continue;
    }

    // Process command and prepare response
    std::string response_data;
    bool need_response = false;

    if (command == COMMAND_INSERT) {
      if (value_size < MIN_INSERT_STR_SIZE) {
        continue;
      }
      data.InsertData(pid, value);
      // No response needed for INSERT
    } else if (command == COMMAND_QUERY) {
      response_data = data.GetHistoryData(pid, value);
      need_response = true;
    } else if (command == COMMAND_QUERYARRAY) {
      auto res = data.GetHistoryDataArray(pid, value);
      for (const auto& str : res) {
        response_data += str + '\n';
      }
      need_response = true;
    } else {
      LOG_E(kTag) << "Invalid command: " << static_cast<int>(command);
      continue;
    }

    // Send response for QUERY commands (even if empty)
    int bytes_write = 0;
    if (need_response) {
      // Prepare ServerMessage using sg_buffer
      size_t msg_size = sizeof(ServerMessage) + response_data.size();
      if (msg_size > BUFFER_MAX_SIZE) {
        LOG_E(kTag) << "Response too large: " << msg_size;
        continue;
      }

      ServerMessage* server_msg = reinterpret_cast<ServerMessage*>(sg_buffer);
      server_msg->seq = seq;
      server_msg->value_size = response_data.size();
      if (response_data.size() > 0) {
        memcpy(server_msg->value, response_data.data(), response_data.size());
      }

      // Send response back to client
      bytes_write = server.SendTo(sg_buffer, msg_size, &client_addr);

      if (bytes_write < 0) {
        LOG_E(kTag) << "SendTo failed";
      } else if (bytes_write == 0) {
        LOG_E(kTag) << "SendTo timeout";
      }
    }

#ifndef NDEBUG
    LOG_I(kTag) << "Processed: command=" << static_cast<int>(command)
                << " pid=" << pid
                << " bytes_write=" << bytes_write
                << " response_size=" << response_data.size();
#endif
  }

  // Clean up
  server.Close();
  LOG_I(kTag) << "================= zsh_server exit ===============";
  return 0;
}
