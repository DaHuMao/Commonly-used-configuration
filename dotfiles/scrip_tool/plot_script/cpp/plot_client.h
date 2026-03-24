#include <functional>
#include <sstream>
namespace plot_plot {
void set_ip_address(const char *ip, int port);
void set_log_callback(std::function<void(const char*)>);
class LogSink {
public:
  static LogSink* get_instance();
  virtual ~LogSink() = default;
  virtual void write(const void *data, size_t size) = 0;
};

enum class LogLevel { kDebug, kInfo, kWarnning, kError };

class LogStream {
public:
  LogStream(LogLevel log_level, const char *tag,
            LogSink* log_client_stream);
  ~LogStream() {
    _stream << '\n';
    _log_client_stream->write(_stream.str().c_str(), _stream.str().size());
  }
  template <class T> LogStream &operator<<(const T &val) {
    _stream << val;
    return *this;
  }

private:
  ::std::ostringstream _stream;
  LogSink *_log_client_stream = nullptr;
};
} // namespace plot_plot
  //
#define DISABLE_PLOT_CLIENT 0

#if DISABLE_PLOT_CLIENT

namespace plot_plot {
class LogStreamNull {
public:
  template <class T> LogStreamNull &operator<<(const T &val) { return *this; }
};
} // namespace plot_plot
#define PLOT_I(tag) plot_plot::LogStreamNull()

#else
#define PLOT_I(tag)                                                            \
  plot_plot::LogStream(plot_plot::LogLevel::kInfo, tag,                        \
                       plot_plot::LogSink::get_instance())
#endif
