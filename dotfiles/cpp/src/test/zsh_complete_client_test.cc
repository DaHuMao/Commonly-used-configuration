#include <cstdio>
#include <cstring>
#include <sstream>
#include <string>
#include <iostream>
#include <unistd.h>
#include "base/local_udp_socket.h"
#include "zsh_complete/define.h"
#include "zsh_complete/message.h"

int main (int argc, char *argv[]) {
  // Get client socket base name
  std::string client_base = GetSocketClientBaseName();
  if (client_base.empty()) {
    printf("Get socket client base name failed\n");
    return 1;
  }

  // Generate unique client path using PID
  std::ostringstream client_path_stream;
  client_path_stream << client_base << "_" << getpid();
  std::string client_path = client_path_stream.str();

  printf("Client starting...\n");
  printf("Client socket path: %s\n", client_path.c_str());

  // Create UDP socket client (non-blocking mode with timeout)
  LocalUdpSocket client(client_path, true);
  if (client.Open() < 0) {
    printf("Failed to open client socket\n");
    return 1;
  }

  // Get server address
  std::string server_path = GetSocketServerBaseName();
  if (server_path.empty()) {
    printf("Get socket server base name failed\n");
    return 1;
  }
  struct sockaddr_un server_addr = LocalUdpSocket::CreateAddress(server_path);

  printf("Server socket path: %s\n", server_path.c_str());
  printf("\nUsage: <command> <value>\n");
  printf("  command: integer command code\n");
  printf("  value: message string (can be empty)\n");
  printf("  /exit: quit the program\n");
  printf("\nExample:\n");
  printf("  %d hello world    (INSERT command)\n", COMMAND_INSERT);
  printf("  %d ls             (QUERY command)\n", COMMAND_QUERY);
  printf("  %d ls             (QUERYARRAY command)\n", COMMAND_QUERYARRAY);
  printf("  /exit              (exit)\n\n");

  int32_t seq = 0;
  char* buffer = nullptr;
  size_t buffer_size = 0;

  // Main interaction loop
  while (true) {
    printf("> ");
    std::string line;

    // Read a line of input
    if (!std::getline(std::cin, line)) {
      // EOF or error
      break;
    }

    // Check for exit command
    if (line == "/exit") {
      printf("Exiting...\n");
      break;
    }

    // Skip empty lines
    if (line.empty()) {
      continue;
    }

    // Parse command and value
    std::istringstream iss(line);
    int command;

    if (!(iss >> command)) {
      printf("Error: Invalid command format. Expected: <command> <value>\n");
      continue;
    }

    // Get the rest as value (may be empty)
    std::string value;
    std::getline(iss >> std::ws, value);

    // Increment sequence number
    ++seq;

    int value_len = value.length();
    printf("Command: %d, Value: '%s' (len=%d), Seq: %d\n",
           command, value.c_str(), value_len, seq);

    // Prepare ClientMessage
    size_t msg_size = sizeof(ClientMessage) + value_len;
    if (msg_size > buffer_size) {
      delete[] buffer;
      buffer = new char[msg_size];
      buffer_size = msg_size;
    }
    ClientMessage* client_msg = reinterpret_cast<ClientMessage*>(buffer);

    client_msg->command = static_cast<int8_t>(command);
    client_msg->seq = seq;
    client_msg->pid = getpid();
    client_msg->value_size = value_len;
    if (value_len > 0) {
      memcpy(client_msg->value, value.c_str(), value_len);
    }

    // Send message with 5 second timeout
    int write_size = client.SendTo(buffer, msg_size, &server_addr, 300);

    if (write_size < 0) {
      printf("Error: Send to socket failed\n");
      continue;
    } else if (write_size == 0) {
      printf("Error: Send timeout\n");
      continue;
    }

    printf("Sent %d bytes (seq=%d)\n", write_size, seq);

    // If it's a QUERY or QUERYARRAY command, wait for response
    if (command == COMMAND_QUERY || command == COMMAND_QUERYARRAY) {
      char recv_buffer[BUFFER_MAX_SIZE];
      int recv_size = client.RecvFrom(recv_buffer, BUFFER_MAX_SIZE, nullptr, 5000);

      if (recv_size < 0) {
        printf("Error: Failed to receive response\n");
      } else if (recv_size == 0) {
        printf("Error: Receive timeout\n");
      } else if (recv_size < static_cast<int>(sizeof(ServerMessage))) {
        printf("Error: Invalid response size: %d\n", recv_size);
      } else {
        // Parse ServerMessage
        ServerMessage* server_msg = reinterpret_cast<ServerMessage*>(recv_buffer);
        int32_t resp_seq = server_msg->seq;
        int32_t resp_value_size = server_msg->value_size;

        if (recv_size == static_cast<int>(sizeof(ServerMessage) + resp_value_size)) {
          printf("Response (seq=%d): ", resp_seq);
          if (resp_value_size > 0) {
            std::string response(server_msg->value, resp_value_size);
            printf("'%s'\n", response.c_str());
          } else {
            printf("(empty)\n");
          }
        } else {
          printf("Error: Response size mismatch\n");
        }
      }
    }

    printf("\n");
  }

  client.Close();
  return 0;
}
