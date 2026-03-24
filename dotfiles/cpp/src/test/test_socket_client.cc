#include "base/local_udp_socket.h"
#include "zsh_complete/define.h"
#include <iostream>
#include <cstring>
#include <unistd.h>
#include <sstream>

int main(int argc, char* argv[]) {
  // Get base path from environment
  std::string base_path = GetSocketClientBaseName();
  if (base_path.empty()) {
    std::cerr << "Error: ZSH_FIFO_DIR environment variable not set" << std::endl;
    return 1;
  }

  // Generate unique client path using PID
  std::ostringstream client_path_stream;
  client_path_stream << base_path << "_" << getpid();
  std::string client_path = client_path_stream.str();

  std::cout << "Client starting..." << std::endl;
  std::cout << "Client socket path: " << client_path << std::endl;
  std::cout << "Server socket path: " << GetSocketServerBaseName() << std::endl;
  std::cout << "Type your messages and press Enter to send." << std::endl;
  std::cout << "Type '/exit' to quit." << std::endl;
  std::cout << std::endl;

  // Create client socket with non-blocking mode
  LocalUdpSocket client(client_path, true);

  if (client.Open() < 0) {
    std::cerr << "Error: Failed to open client socket" << std::endl;
    return 1;
  }

  // Create server address using static helper
  struct sockaddr_un server_addr = LocalUdpSocket::CreateAddress(GetSocketServerBaseName());

  // Main input/output loop
  while (true) {
    std::cout << "> ";
    std::string message;

    // Read a line of input
    if (!std::getline(std::cin, message)) {
      // EOF or error
      break;
    }

    // Check for exit command
    if (message == "/exit") {
      std::cout << "Exiting..." << std::endl;
      break;
    }

    // Skip empty messages
    if (message.empty()) {
      continue;
    }

    // Send message to server with 5 second timeout
    int sent = client.SendTo(message.c_str(), message.length(), &server_addr, 5000);

    if (sent < 0) {
      std::cerr << "Error: Failed to send message" << std::endl;
      continue;
    } else if (sent == 0) {
      std::cerr << "Error: Send timeout" << std::endl;
      continue;
    }

    // Receive response from server with 5 second timeout
    char buffer[1024];
    int received = client.RecvFrom(buffer, sizeof(buffer) - 1, nullptr, 5000);

    if (received < 0) {
      std::cerr << "Error: Failed to receive response" << std::endl;
      continue;
    } else if (received == 0) {
      std::cerr << "Error: Receive timeout (server not responding)" << std::endl;
      continue;
    }

    // Null-terminate and print response
    buffer[received] = '\0';
    std::cout << "Server: " << buffer << std::endl;
  }

  client.Close();
  return 0;
}
