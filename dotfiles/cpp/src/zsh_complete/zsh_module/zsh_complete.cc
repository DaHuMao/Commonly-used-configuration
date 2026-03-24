#include <unistd.h>

#include <cstring>
#include <sstream>

#include "base/local_udp_socket.h"
#include "base/log.h"
#include "define.h"
#include "zsh_complete/message.h"
#include "zsh_util/function_load.h"

#include "zsh_complete.mdh"
static std::unique_ptr<LocalUdpSocket> socket_client;
static struct sockaddr_un server_addr;
static char sg_buffer[BUFFER_MAX_SIZE];

static int64_t sg_message_seq = 0;
static int64_t sg_resp_seq = 0;
static constexpr int64_t clear_message_count_min_min_gap = 10;
static int64_t test_seq = 0;
static std::string socket_client_file_path = "";

// zsh_complete_insert函数
static int zsh_complete_insert(UNUSED(char *name), char **args, Options ops,
                               UNUSED(int func)) {
  int key = atoi(args[0]);
  int len = strlen(args[1]);
  char *value = zsh_util::UnMetafy(args[1], &len);

  // Prepare ClientMessage using sg_buffer
  size_t msg_size = sizeof(ClientMessage) + len;
  if (msg_size > BUFFER_MAX_SIZE) {
    return -1;  // Message too large
  }

  ClientMessage *client_msg = reinterpret_cast<ClientMessage *>(sg_buffer);
  client_msg->command = COMMAND_INSERT;
  client_msg->seq = 0;  // INSERT doesn't need seq
  client_msg->pid = key;
  client_msg->value_size = len;
  memcpy(client_msg->value, value, len);

  // Send with timeout
  socket_client->SendTo(sg_buffer, msg_size, &server_addr, 600);

  if (sg_message_seq != sg_resp_seq) {
    // Clear any pending responses by reading with timeout
    while (socket_client->RecvFrom(sg_buffer, BUFFER_MAX_SIZE, nullptr, 10) >
           0) {
      // Drain the socket
    }
    sg_resp_seq = sg_message_seq;
  }
  return 0;
}
static constexpr char kRandomFlagStr[] = "kkkkkkkkkkkkkkkkkdsmadskakdlsa";
static std::string last_query_value = kRandomFlagStr;
static std::string last_query_result = "";
static void qurry_str(int key, const char *value, bool need_array) {
  static bool last_need_array = false;

  int value_len = strlen(value);

  // 优化：如果上次查询是当前查询的前缀，且上次无结果，则这次也不会有结果
  // 例如：上次查询 "xyzabc"（无结果），当前查询 "xyzabcdef"
  // 逻辑：短的都匹配不到，长的更不可能匹配到
  if (last_query_value.size() > 0 &&
      last_query_result.size() == 0 &&
      value_len >= (int)last_query_value.size() &&
       strncmp(value, last_query_value.c_str(), last_query_value.size()) == 0) {
    return;
  }

  last_need_array = need_array;
  ++sg_message_seq;

  // Prepare ClientMessage using sg_buffer
  size_t msg_size = sizeof(ClientMessage) + value_len;
  if (msg_size > BUFFER_MAX_SIZE) {
    zsh_util::SetParamPtr("COMPLETE_REPLY", "");
    return;  // Message too large
  }

  ClientMessage *client_msg = reinterpret_cast<ClientMessage *>(sg_buffer);
  client_msg->command = need_array ? COMMAND_QUERYARRAY : COMMAND_QUERY;
  client_msg->seq = sg_message_seq;
  client_msg->pid = key;
  client_msg->value_size = value_len;
  memcpy(client_msg->value, value, value_len);

  // Send query
  const int write_size =
      socket_client->SendTo(sg_buffer, msg_size, &server_addr, -1);

  bool has_updated = false;
  int timeout_ms = need_array ? 300 : 100;
  if (write_size > 0) {
    while (sg_resp_seq < sg_message_seq) {
      // Use timeout for receiving response (100ms per try)
      const int read_size = socket_client->RecvFrom(sg_buffer, BUFFER_MAX_SIZE,
                                                    nullptr, timeout_ms);
      if (read_size > 0) {
        // Parse ServerMessage
        if (read_size < static_cast<int>(sizeof(ServerMessage))) {
          continue;
        }

        ServerMessage *server_msg =
            reinterpret_cast<ServerMessage *>(sg_buffer);
        int32_t resp_seq = server_msg->seq;
        int32_t resp_value_size = server_msg->value_size;

        // Validate message
        if (read_size !=
            static_cast<int>(sizeof(ServerMessage) + resp_value_size)) {
          continue;
        }

        if (sg_message_seq == resp_seq) {
          has_updated = true;
          sg_resp_seq = resp_seq;
          last_query_value = value;
          last_query_result =
              std::string(server_msg->value, resp_value_size);

          // 将服务器返回的普通字符串转换为 ZSH 内部格式
          char *metafied_str =
              zsh_util::Metafy(server_msg->value, resp_value_size);
          zsh_util::SetParamPtr("COMPLETE_REPLY", metafied_str);
          break;
        }
      } else {
        break;
      }
    }
  }
  if (!has_updated) {
    // 超时未收到响应，设置为默认字符串
    last_query_value = kRandomFlagStr;
    last_query_result = "";
    zsh_util::SetParamPtr("COMPLETE_REPLY", "");
  }
}

// zsh_complete_query函数
static int zsh_complete_query(UNUSED(char *name), char **args, Options ops,
                              UNUSED(int func)) {
  int key = atoi(args[0]);
  char *value = args[1];
  qurry_str(key, value, false);
  return 0;
}

// zsh_complete_query_array函数
static int zsh_complete_query_array(UNUSED(char *name), char **args,
                                    Options ops, UNUSED(int func)) {
  int key = atoi(args[0]);
  char *value = args[1];
  qurry_str(key, value, true);
  return 0;
}

static int zsh_complete_termina_exit(UNUSED(char *name), UNUSED(char **args),
                                     UNUSED(Options ops), UNUSED(int func)) {
  int key = atoi(args[0]);

  // Prepare ClientMessage using sg_buffer
  size_t msg_size = sizeof(ClientMessage);
  ClientMessage *client_msg = reinterpret_cast<ClientMessage *>(sg_buffer);

  client_msg->command = COMMAND_TERMINAL_EXIT;
  client_msg->seq = 0;
  client_msg->pid = key;
  client_msg->value_size = 0;

  socket_client->SendTo(sg_buffer, msg_size, &server_addr, -1);
  socket_client->Close();
  LOG_I("zsh_complete") << "Terminal exit sent for pid=" << key;
  return 0;
}

static int zsh_complete_server_exit(UNUSED(char *name), UNUSED(char **args),
                                    UNUSED(Options ops), UNUSED(int func)) {
  // Prepare ClientMessage using sg_buffer
  size_t msg_size = sizeof(ClientMessage);
  ClientMessage *client_msg = reinterpret_cast<ClientMessage *>(sg_buffer);

  client_msg->command = COMMAND_EXIT;
  client_msg->seq = 0;
  client_msg->pid = 0;
  client_msg->value_size = 0;

  socket_client->SendTo(sg_buffer, msg_size, &server_addr, -1);
  return 0;
}

static int flags =
    BINF_BUILTIN | BINF_NOGLOB | BINF_SKIPINVALID | BINF_HANDLES_OPTS;
static struct builtin bintab[] = {
    BUILTIN("zsh_complete_insert", flags, zsh_complete_insert, 2, 2, 0,
            "key value", NULL),
    BUILTIN("zsh_complete_query", flags, zsh_complete_query, 2, 2, 0,
            "key value", NULL),
    BUILTIN("zsh_complete_query_array", flags, zsh_complete_query_array, 2, 2,
            0, "key value", NULL),
    BUILTIN("zsh_complete_termina_exit", flags, zsh_complete_termina_exit, 1, 1,
            0, "key", NULL),
    BUILTIN("zsh_complete_server_exit", flags, zsh_complete_server_exit, 0, 0,
            0, "", NULL),
};

int setup_(Module m) {
  int res = 0;
  LogStream::SetLogLevel(LogLevel::kInfo);

  zsh_util::InitFunctionLoad();

  // Get client socket base name
  std::string client_base = GetSocketClientBaseName();
  if (client_base.size() == 0) {
    LOG_E("zsh_complete") << "Get socket client base name failed";
    return 1;
  }

  // Generate unique client path using PID
  std::ostringstream client_path_stream;
  client_path_stream << client_base << "_" << getpid();
  socket_client_file_path = client_path_stream.str();

  // Create UDP socket client (non-blocking mode)
  socket_client = std::make_unique<LocalUdpSocket>(socket_client_file_path, true);
  if (socket_client->Open() < 0) {
    LOG_E("zsh_complete") << "Failed to open client socket";
    return 1;
  }

  // Get server address
  std::string server_path = GetSocketServerBaseName();
  if (server_path.size() == 0) {
    LOG_E("zsh_complete") << "Get socket server base name failed";
    return 1;
  }
  server_addr = LocalUdpSocket::CreateAddress(server_path);

  zsh_util::SetParamPtr("SOCKET_CLIENT_FILE_PATH", socket_client_file_path.c_str());

  printf("zsh_complete setup: client=%s, server=%s\n", socket_client_file_path.c_str(),
         server_path.c_str());
  return res;
}

int boot_(Module m) {
  return addbuiltins("zsh_complete", bintab, sizeof(bintab) / sizeof(*bintab));
}

int cleanup_(Module m) {
  if (socket_client) {
    socket_client->Close();
    socket_client.reset();
  }
  return 0;
}

int finish_(Module m) { return 0; }
