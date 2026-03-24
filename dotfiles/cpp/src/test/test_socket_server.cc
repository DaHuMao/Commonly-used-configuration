#include "base/local_udp_socket.h"
#include "zsh_complete/define.h"
#include <iostream>
#include <cstring>

int main() {
  // Get base path from environment
  std::string base_path = GetSocketServerBaseName();
  if (base_path.empty()) {
    std::cerr << "Error: ZSH_FIFO_DIR environment variable not set" << std::endl;
    return 1;
  }

  std::cout << "Server starting with socket: " << base_path << std::endl;

  // Create server socket (blocking mode)
  LocalUdpSocket server(base_path, false);

  if (server.Open() < 0) {
    std::cerr << "Error: Failed to open server socket" << std::endl;
    return 1;
  }

  std::cout << "Server is listening..." << std::endl;

  // Main server loop
  while (true) {
    char buffer[1024];
    struct sockaddr_un client_addr;

    // Receive message from client
    int received = server.RecvFrom(buffer, sizeof(buffer) - 1, &client_addr);

    if (received < 0) {
      std::cerr << "Error receiving data" << std::endl;
      continue;
    }

    if (received == 0) {
      continue;
    }

    // Null-terminate the received data
    buffer[received] = '\0';

    std::cout << "Received from client (" << client_addr.sun_path << "): " << buffer << std::endl;

    // Add "response" to the message
    std::string response = std::string(buffer) + " response";

    // Send response back to client
    int sent = server.SendTo(response.c_str(), response.length(), &client_addr);

    if (sent < 0) {
      std::cerr << "Error sending response" << std::endl;
      continue;
    }

    std::cout << "Sent to client: " << response << std::endl;
  }

  server.Close();
  return 0;
}
