#ifndef SRC_LOG_H_
#define SRC_LOG_H_
#include <functional>
#include <sstream>
#include <string>
enum class LogLevel { kDebug, kInfo, kWarnning, kError, kFatal };

struct LogCallBack {
  std::function<void(const std::string)> call_back;
  std::function<void()> flush;
};

class LogStream {
public:
  LogStream(LogLevel log_level, const char* file, int line, const char *tag);

  ~LogStream();
  template <class T> LogStream &operator<<(const T &val) {
    stream_ << val;
    return *this;
  }

static void SetLogLevel(LogLevel log_level);
static void SetLogCallBack(const LogCallBack &log_call_back);

private:
  std::ostringstream stream_;
  LogLevel log_level_;
};

#define LOG_D(tag) LogStream(LogLevel::kDebug, __FILE__, __LINE__, tag)
#define LOG_I(tag) LogStream(LogLevel::kInfo, __FILE__, __LINE__, tag)
#define LOG_W(tag) LogStream(LogLevel::kWarnning, __FILE__, __LINE__, tag)
#define LOG_E(tag) LogStream(LogLevel::kError, __FILE__, __LINE__, tag)
#define LOG_F(tag) LogStream(LogLevel::kFatal, __FILE__, __LINE__, tag)
#endif // SRC_LOG_H_
