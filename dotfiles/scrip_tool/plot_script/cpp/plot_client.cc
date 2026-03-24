#include "plot_client.h"

#include <queue>
#include <thread>
#include <chrono>
#include <mutex>
#include <cassert>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "Ws2_32.lib")
#else
#include <arpa/inet.h>
#include <errno.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#endif

#include <cstdarg>
#include <unordered_map>

#include "components/perf/perf_guardian.h"
namespace plot_plot {
static std::string gs_ip_address = "10.1.104.73";
static int gs_ip_port = 9600;
static std::function<void(const char *)> gs_log_callback = nullptr;

void out_log(const char *format, ...) {
  static char buffer[1024] = {0};
  va_list args;
  va_start(args, format);
  vsnprintf(buffer, sizeof(buffer), format, args);
  va_end(args);
  if (gs_log_callback == nullptr) {
    printf("%s", buffer);
  } else {
    gs_log_callback(buffer);
  }
}

void set_ip_address(const char *ip, int port) {
  gs_ip_address = ip;
  gs_ip_port = port;
}

void set_log_callback(std::function<void(const char *)> log_callback) {
  gs_log_callback = std::move(log_callback);
}

class SocketForLog {
 public:
  SocketForLog();
  ~SocketForLog();
  void write(const void *data, size_t size);
  void try_connect();

 private:
  int write_n(const void *data, size_t size);
#if defined(_WIN32) || defined(_WIN64)
  SOCKET _socket_fd = INVALID_SOCKET;
#else
  int _socket_fd = -1;
#endif
};

SocketForLog::SocketForLog() {
#if defined(_WIN32) || defined(_WIN64)
  // Windows 需要初始化 Winsock
  WSADATA wsaData;
  if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
    out_log("WSAStartup failed: %d\n", WSAGetLastError());
  }
#endif
}

#if defined(_WIN32) || defined(_WIN64)
SocketForLog::~SocketForLog() {
  if (_socket_fd != INVALID_SOCKET) {
    closesocket(_socket_fd);
    _socket_fd = INVALID_SOCKET;
  }
  WSACleanup();
}

void SocketForLog::try_connect() {
  if (_socket_fd != INVALID_SOCKET) {
    return;
  }

  const char *ip_address = gs_ip_address.c_str();
  int ip_port = gs_ip_port;

  _socket_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (_socket_fd == INVALID_SOCKET) {
    out_log("socket creation failed: %d\n", WSAGetLastError());
    return;
  }

  struct sockaddr_in t_sockaddr;
  memset(&t_sockaddr, 0, sizeof(struct sockaddr_in));
  t_sockaddr.sin_family = AF_INET;
  t_sockaddr.sin_port = htons(ip_port);

  if (inet_pton(AF_INET, ip_address, &t_sockaddr.sin_addr) <= 0) {
    out_log("Invalid address/Address not supported: %d\n", WSAGetLastError());
    closesocket(_socket_fd);
    _socket_fd = INVALID_SOCKET;
    return;
  }

  if (connect(_socket_fd, (struct sockaddr *)&t_sockaddr, sizeof(t_sockaddr)) ==
      SOCKET_ERROR) {
    out_log("connect failed: %d\n", WSAGetLastError());
    closesocket(_socket_fd);
    _socket_fd = INVALID_SOCKET;
    std::this_thread::sleep_for(std::chrono::milliseconds(1 * 1000));
    return;
  }

  out_log("connect success\n");
}

void SocketForLog::write(const void *data, size_t size) {
  if (_socket_fd == INVALID_SOCKET) {
    return;
  }

  if (write_n(data, size) < 0) {
    out_log("send message error: %d\n", WSAGetLastError());
    closesocket(_socket_fd);
    _socket_fd = INVALID_SOCKET;
  }
}

int SocketForLog::write_n(const void *data, size_t size) {
  int bytes_left = static_cast<int>(size);
  int written_bytes = 0;
  const char *ptr = reinterpret_cast<const char *>(data);

  while (bytes_left > 0) {
    written_bytes = send(_socket_fd, ptr, bytes_left, 0);
    if (written_bytes == SOCKET_ERROR) {
      int error = WSAGetLastError();
      if (error == WSAEWOULDBLOCK || error == WSAEINTR) {
        continue;
      }
      return -1;
    }
    bytes_left -= written_bytes;
    ptr += written_bytes;
  }
  return 0;
}
#else
SocketForLog::~SocketForLog() {
  if (_socket_fd > 0) {
    close(_socket_fd);
    _socket_fd = -1;
  }
}

void SocketForLog::try_connect() {
  if (_socket_fd > 0) {
    return;
  }
  const char *ip_address = gs_ip_address.c_str();
  int ip_port = gs_ip_port;
  _socket_fd = socket(AF_INET, SOCK_STREAM, 0);
  if (_socket_fd < 0) {
    return;
  }
  struct sockaddr_in t_sockaddr;
  memset(&t_sockaddr, 0, sizeof(struct sockaddr_in));
  t_sockaddr.sin_family = AF_INET;
  t_sockaddr.sin_port = htons(ip_port);
  inet_pton(AF_INET, ip_address, &t_sockaddr.sin_addr);
  int ret = 0;
  if ((ret = ::connect(_socket_fd, (struct sockaddr *)&t_sockaddr,
                       sizeof(struct sockaddr))) < 0) {
    out_log("ztx_test connect error %s %d\n", strerror(errno), ret);
    close(_socket_fd);
    _socket_fd = -1;
    std::this_thread::sleep_for(std::chrono::milliseconds(1 * 1000));
    return;
  }
  out_log("ztx_test connect sucess\n");
}

void SocketForLog::write(const void *data, size_t size) {
  if (_socket_fd < 0) {
    return;
  }
  if (write_n(data, size) < 0) {
    out_log("ztx_test send message error: %s errno : %d\n", strerror(errno),
            errno);
    _socket_fd = -1;
  }
}

int SocketForLog::write_n(const void *data, size_t size) {
  int bytes_left = size;
  int written_bytes = 0;
  const char *ptr = reinterpret_cast<const char *>(data);
  while (bytes_left > 0) {
    written_bytes = ::write(_socket_fd, ptr, bytes_left);
    if (written_bytes <= 0) {
      if (errno == EINTR) {
        written_bytes = 0;
      } else {
        return -1;
      }
    }
    bytes_left -= written_bytes;
    ptr += written_bytes;
  }
  return 0;
}
#endif

struct SimpleBuffer {
  char *_data = nullptr;
  size_t capacity = 0;
  size_t size = 0;
  void Write(const void *data, size_t data_size) {
    if (data_size > capacity) {
      if (_data != nullptr)
        delete[] _data;
      capacity = data_size;
      _data = new char[capacity];
      size = 0;
    }
    memcpy(_data, data, data_size);
    size = data_size;
  }
};

class LogClientStream final : public LogSink {
 public:
  LogClientStream(std::function<void(const void *, size_t)>);
  ~LogClientStream();
  void register_callback(std::function<void(const void *data, size_t size)>);
  void write(const void *data, size_t size);

 private:
  static void run_thread(void *handle);

  void run();
  bool read();

  SimpleBuffer get_free_buffer() {
    if (_free_queue.empty()) {
      return SimpleBuffer();
    } else {
      std::lock_guard<std::mutex> lk(_free_queue_mutex);
      SimpleBuffer buffer = std::move(_free_queue.front());
      _free_queue.pop();
      return buffer;
    }
  }

  SimpleBuffer get_data_buffer() {
    if (_data_queue.empty()) {
      return SimpleBuffer();
    } else {
      std::lock_guard<std::mutex> lk(_data_queue_mutex);
      SimpleBuffer buffer = std::move(_data_queue.front());
      _data_queue.pop();
      return buffer;
    }
  }

  size_t _cur_read_index = 0;
  size_t _cur_write_index = 0;
  ::std::function<void(const void *, size_t)> _call_back;
  bool _is_stop;
  ::std::thread _thread_t;
  ::std::mutex _data_queue_mutex;
  ::std::mutex _free_queue_mutex;
  std::queue<SimpleBuffer> _data_queue;
  std::queue<SimpleBuffer> _free_queue;
};


size_t kDataStreamVectorMaxSize = 1000;
static SocketForLog sockt_sink;
LogSink *LogSink::get_instance() {
  static LogClientStream log_client_stream(
      [](const void *data, size_t size) { sockt_sink.write(data, size); });
  return &log_client_stream;
}

void LogClientStream::run_thread(void *handle) {
  static_cast<LogClientStream *>(handle)->run();
}

LogClientStream::LogClientStream(
    std::function<void(const void *, size_t)> call_back)
    : _call_back(call_back) {
  _is_stop = false;
  _thread_t = std::thread(run_thread, this);
}

LogClientStream::~LogClientStream() {
  _is_stop = true;
  _thread_t.join();
}

void LogClientStream::run() {
  yuanli::components::PerfGuardian::Instance()->AddWatchThread(
      yuanli::base::system::GetCurrentThreadId(), "PlotThread");
  while (!_is_stop) {
    sockt_sink.try_connect();
    if (!_data_queue.empty()) {
      auto buffer = get_data_buffer();
      _call_back(buffer._data, buffer.size);
      {
        std::lock_guard<std::mutex> lk(_free_queue_mutex);
        _free_queue.push(buffer);
      }
    } else {
      std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
  }
}

void LogClientStream::write(const void *data, size_t size) {
  auto buffer = get_free_buffer();
  buffer.Write(data, size);
  if (_data_queue.size() > kDataStreamVectorMaxSize) {
    assert(false);
    auto old_buffer = get_data_buffer();
    {
      std::lock_guard<std::mutex> lk(_free_queue_mutex);
      _free_queue.push(old_buffer);
    }
  }
  std::lock_guard<std::mutex> lk2(_data_queue_mutex);
  _data_queue.push(std::move(buffer));
}

struct MyKeyHashHasher {
  size_t operator()(const LogLevel &level) const noexcept {
    return static_cast<size_t>(level);
  }
};

const std::unordered_map<LogLevel, const char *, MyKeyHashHasher>
    kLogLeveToString = {{LogLevel::kDebug, "DEBUG: "},
                        {LogLevel::kInfo, "INFO: "},
                        {LogLevel::kWarnning, "WARN: "},
                        {LogLevel::kError, "ERROR: "}};

LogStream::LogStream(LogLevel log_level, const char *tag,
                     LogSink *log_client_stream)
    : _log_client_stream(log_client_stream) {
  _stream << kLogLeveToString.find(log_level)->second << tag << ": ";
}
}  // namespace plot_plot
