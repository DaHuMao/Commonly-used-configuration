#include <sstream>
#include <string>
#include <vector>
#include <mutex>
#include <functional>
#include <thread>
namespace  plot_plot {
void set_ip_address(const std::string& ip, int port);
class DataSrtream final {
public:
    DataSrtream(size_t init_size, std::function<void(const void*, size_t)> call_back);
    ~DataSrtream();
    bool write(const void* data, size_t size);
    bool sprintf(const char* format, ...);
    bool read();
private:
    const size_t _size;
    int8_t* _data = nullptr;
    size_t _writed_size = 0;
    std::mutex _mutex;
    bool _can_be_read = false;
    std::function<void(const void*, size_t)> _call_back;
    static char kSplitCharFlag;
};

class LogClientStream final {
public:
    static LogClientStream& get_instance();
    LogClientStream(std::function<void(const void*, size_t)>);
    ~LogClientStream();
    void register_callback(std::function<void(const void* data, size_t size)>);
    void log(const char* format, ...);
    void write(const void* data, size_t size);
private:
    static void run_thread(void* handle);
    static size_t kDataStreamVectorMaxSize;
    static size_t kDataStreamInitSize;

    void run();
    bool read(); 
    void resize_vector_and_write(const void* data, size_t size);

    size_t _cur_read_index = 0;
    size_t _cur_write_index = 0;
    std::function<void(const void*, size_t)> _call_back;
    std::vector<std::unique_ptr<DataSrtream>> _data_stream_vector;
    bool _is_stop;
    std::thread _thread_t;
    std::mutex _mutex;
};

enum class LogLevel {
    kDebug,
    kInfo,
    kWarnning,
    kError
};

#include <iostream>
class LogStream {
public:
    LogStream(LogLevel log_level, const char* tag, LogClientStream& log_client_stream);
    ~LogStream() {
        static int count = 0;
        _stream << '\n';
        _log_client_stream.write(_stream.str().c_str(), _stream.str().size());
    }
    template <class T>
    LogStream& operator<<(const T& val) {
        _stream << val;
        return *this;
    }
private:
    std::ostringstream _stream;
    LogClientStream& _log_client_stream;
};
} // plot_plot

#define LOG_I(tag) LogStream(LogLevel::kInfo, tag, plot_plot::LogClientStream::get_instance())
