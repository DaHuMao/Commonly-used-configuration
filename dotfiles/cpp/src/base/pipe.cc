#include "base/pipe.h"

#include "base/check.h"
#include "base/log.h"
#if defined(UNIX_LIKE_PLATFORM)
#include <sys/fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
constexpr const char* kTag = "Pipe";
PipeReader::PipeReader(const std::string& path, bool is_blocking)
    : path_(path), is_blocking_(is_blocking) {
  int res = mkfifo(path.c_str(), 0666);
  if (res == -1) {
    if (errno != EEXIST) {
      DCHECK(false);
      LOG_E(kTag) << "mkfifo failed, errno: " << strerror(errno)
                  << " fifo path: " << path;
    }
  }
  if (is_blocking) {
    fd_ = open(path.c_str(), O_RDONLY);
  } else {
    fd_ = open(path.c_str(), O_RDONLY | O_NONBLOCK);
  }
  if (fd_ == -1) {
    DCHECK(false);
    LOG_E(kTag) << "read open fifo failed, errno: " << strerror(errno)
                << " fifo path: " << path;
  } else {
    LOG_I(kTag) << "reader open fifo success, path: " << path;
  }
}

PipeReader::~PipeReader() {
  if (fd_ != -1) {
    close(fd_);
    // unlink(path_.c_str());
  }
}

int PipeReader::Read(char* buffer, int size, int wait_timeout_ms) {
  if (fd_ == -1) {
    return -1;
  }
  if (is_blocking_) {
    return read(fd_, buffer, size);
  } else {
    fd_set readfds;
    struct timeval tv;
    FD_ZERO(&readfds);
    FD_SET(fd_, &readfds);
    tv.tv_sec = 0;
    tv.tv_usec = wait_timeout_ms;
    int ret = select(fd_ + 1, &readfds, NULL, NULL, &tv);
    if (ret == -1) {
      LOG_E(kTag) << "select failed";
      return -1;
    } else if (ret > 0) {
      if (FD_ISSET(fd_, &readfds)) {
        return read(fd_, buffer, size);
      }
    }
    return 0;
  }
}

void PipeReader::ClearPipeBuffer() {
  if (fd_ == -1) {
    return;
  }
  static char buffer[1024];
  while (true) {
    int read_size = Read(buffer, sizeof(buffer));
    if (read_size <= 0) {
      break;
    }
  }
}

PipeWriter::PipeWriter(const std::string& path, bool is_blocking)
    : path_(path), is_blocking_(is_blocking) {
  int res = mkfifo(path.c_str(), 0666);
  if (res == -1) {
    if (errno != EEXIST) {
      DCHECK(false);
      LOG_E(kTag) << "mkfifo failed, errno: " << strerror(errno)
                  << " fifo path: " << path;
    }
  }
  if (is_blocking) {
    fd_ = open(path.c_str(), O_WRONLY);
  } else {
    fd_ = open(path.c_str(), O_WRONLY | O_NONBLOCK);
  }
  if (fd_ == -1) {
    DCHECK(false);
    LOG_E(kTag) << "write open fifo failed, errno: " << strerror(errno)
                << " fifo path: " << path;
  } else {
    LOG_I(kTag) << "writer open fifo success, path: " << path;
  }
}

PipeWriter::~PipeWriter() {
  if (fd_ != -1) {
    close(fd_);
    // unlink(path_.c_str());
  }
}

int PipeWriter::Write(const char* buffer, int size, int wait_timeout_ms) {
  if (fd_ == -1) {
    return -1;
  }
  int write_size = 0;
  if (is_blocking_) {
    write_size = write(fd_, buffer, size);
  } else {
    fd_set writefds;
    struct timeval tv;
    FD_ZERO(&writefds);
    FD_SET(fd_, &writefds);
    tv.tv_sec = 0;
    tv.tv_usec = wait_timeout_ms;
    int ret = select(fd_ + 1, NULL, &writefds, NULL, &tv);
    if (ret == -1) {
      LOG_E(kTag) << "select failed";
      return -1;
    } else if (ret > 0) {
      if (FD_ISSET(fd_, &writefds)) {
        write_size = write(fd_, buffer, size);
      }
    }
  }
  fsync(fd_);
  return write_size;
}
#endif
