#ifndef BASE_PIPE_H_
#define BASE_PIPE_H_
#include <string>
class PipeReader final {
 public:
  PipeReader(const std::string& path, bool is_blocking = true);
  ~PipeReader();
  // 第三个参数仅在非阻塞模式下有效
  int Read(char* buffer, int size, int wait_timeout_ms = 200);
  void ClearPipeBuffer();
  bool IsValid() const { return fd_ != -1; }

 private:
  int fd_ = -1;
  std::string path_;
  bool is_blocking_ = true;
};

class PipeWriter final {
 public:
  PipeWriter(const std::string& path, bool is_blocking = true);
  ~PipeWriter();
  // 第三个参数仅在非阻塞模式下有效
  int Write(const char* buffer, int size, int wait_timeout_ms = 200);
  bool IsValid() const { return fd_ != -1; }

 private:
  int fd_ = -1;
  std::string path_;
  bool is_blocking_ = true;
};
#endif  // BASE_PIPE_H_
