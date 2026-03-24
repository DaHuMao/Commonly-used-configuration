#ifndef BASE_LOCAL_UDP_SOCKET_H_
#define BASE_LOCAL_UDP_SOCKET_H_
#include <string>
#include <sys/un.h>

class LocalUdpSocket final {
 public:
  // Constructor
  // path: full socket path (caller is responsible for generating unique path)
  // non_blocking: true to enable non-blocking mode
  LocalUdpSocket(const std::string& path, bool non_blocking = false);
  ~LocalUdpSocket();
  int Open();

  // SendTo with optional timeout (only works in non-blocking mode)
  // timeout_ms: maximum blocking time in milliseconds, -1 means no timeout
  int SendTo(const char* buffer, int size, const struct sockaddr_un* dest_addr, int timeout_ms = -1);

  // RecvFrom with optional timeout (only works in non-blocking mode)
  // timeout_ms: maximum blocking time in milliseconds, -1 means no timeout
  int RecvFrom(char* buffer, int capacity, struct sockaddr_un* src_addr, int timeout_ms = -1);

  int Close();

  // Static helper to create socket address from path
  static struct sockaddr_un CreateAddress(const std::string& path);

 private:
  int fd_ = -1;
  std::string path_;
  bool non_blocking_;
};
#endif  // BASE_LOCAL_UDP_SOCKET_H_
