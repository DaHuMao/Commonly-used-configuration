#include "local_udp_socket.h"
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/select.h>
#include <cstring>
#include <errno.h>

LocalUdpSocket::LocalUdpSocket(const std::string& path, bool non_blocking)
    : path_(path),
      non_blocking_(non_blocking) {
  // Create Unix domain socket with UDP (SOCK_DGRAM)
  fd_ = socket(AF_UNIX, SOCK_DGRAM, 0);

  // Set non-blocking mode if requested
  if (fd_ >= 0 && non_blocking_) {
    int flags = fcntl(fd_, F_GETFL, 0);
    if (flags >= 0) {
      fcntl(fd_, F_SETFL, flags | O_NONBLOCK);
    }
  }
}

LocalUdpSocket::~LocalUdpSocket() {
  Close();
}

int LocalUdpSocket::Open() {
  if (fd_ < 0) {
    return -1;
  }

  struct sockaddr_un addr;
  memset(&addr, 0, sizeof(addr));
  addr.sun_family = AF_UNIX;

  if (path_.length() >= sizeof(addr.sun_path)) {
    return -1;  // path too long
  }

  strncpy(addr.sun_path, path_.c_str(), sizeof(addr.sun_path) - 1);

  // Remove old socket file before binding
  unlink(path_.c_str());

  // Bind to the address
  if (bind(fd_, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
    return -1;
  }

  return 0;
}

int LocalUdpSocket::SendTo(const char* buffer, int size, const struct sockaddr_un* dest_addr, int timeout_ms) {
  if (fd_ < 0 || !buffer || size <= 0 || !dest_addr) {
    return -1;
  }

  // Handle timeout in non-blocking mode
  if (non_blocking_ && timeout_ms >= 0) {
    fd_set write_fds;
    FD_ZERO(&write_fds);
    FD_SET(fd_, &write_fds);

    struct timeval timeout;
    timeout.tv_sec = timeout_ms / 1000;
    timeout.tv_usec = (timeout_ms % 1000) * 1000;

    int ret = select(fd_ + 1, nullptr, &write_fds, nullptr, &timeout);
    if (ret <= 0) {
      return ret;  // timeout or error
    }
  }

  int sent = sendto(fd_, buffer, size, 0,
                    (struct sockaddr*)dest_addr, sizeof(*dest_addr));
  return sent;
}

int LocalUdpSocket::RecvFrom(char* buffer, int capacity, struct sockaddr_un* src_addr, int timeout_ms) {
  if (fd_ < 0 || !buffer || capacity <= 0) {
    return -1;
  }

  // Handle timeout in non-blocking mode
  if (non_blocking_ && timeout_ms >= 0) {
    fd_set read_fds;
    FD_ZERO(&read_fds);
    FD_SET(fd_, &read_fds);

    struct timeval timeout;
    timeout.tv_sec = timeout_ms / 1000;
    timeout.tv_usec = (timeout_ms % 1000) * 1000;

    int ret = select(fd_ + 1, &read_fds, nullptr, nullptr, &timeout);
    if (ret <= 0) {
      return ret;  // timeout or error
    }
  }

  struct sockaddr_un temp_addr;
  socklen_t addr_len = sizeof(temp_addr);

  int received = recvfrom(fd_, buffer, capacity, 0,
                          (struct sockaddr*)&temp_addr, &addr_len);

  // Copy source address if provided
  if (received > 0 && src_addr) {
    memcpy(src_addr, &temp_addr, sizeof(temp_addr));
  }

  return received;
}

int LocalUdpSocket::Close() {
  if (fd_ >= 0) {
    close(fd_);
    fd_ = -1;

    // Remove socket file
    unlink(path_.c_str());
  }
  return 0;
}

struct sockaddr_un LocalUdpSocket::CreateAddress(const std::string& path) {
  struct sockaddr_un addr;
  memset(&addr, 0, sizeof(addr));
  addr.sun_family = AF_UNIX;
  strncpy(addr.sun_path, path.c_str(), sizeof(addr.sun_path) - 1);
  return addr;
}
