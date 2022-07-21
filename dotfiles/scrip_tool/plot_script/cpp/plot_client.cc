#include "plot_client.h"

#include <arpa/inet.h>
#include <errno.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#include <cstdarg>
#include <memory>
#include <unordered_map>
namespace plot_plot {
static std::string gs_ip_address = "172.24.220.219";
static int gs_ip_port = 9600;

void set_ip_address(const char* ip, int port) {
    gs_ip_address = ip;
    gs_ip_port = port;
}

class SocketForLog {
public:
    SocketForLog();
    ~SocketForLog();
    void write(const void* data, size_t size);
    void try_connect();
private:
    int write_n(const void* data, size_t size);
    int _socket_fd = -1;
};

SocketForLog::SocketForLog() {}

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
    const char* ip_address = gs_ip_address.c_str();
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
    if((ret = ::connect(_socket_fd, (struct sockaddr*)&t_sockaddr, sizeof(struct sockaddr))) < 0 ) {
        printf("ztx_test connect error %s %d", strerror(errno), ret);
        close(_socket_fd);
        _socket_fd = -1;
        std::this_thread::sleep_for(std::chrono::milliseconds(1 * 1000));
        return;
    }
    printf("ztx_test connect sucess");
}

void SocketForLog::write(const void *data, size_t size) {
    if (_socket_fd < 0) {
        return;
    }
    if(write_n(data, size) < 0) {
        printf("ztx_test send message error: %s errno : %d", strerror(errno), errno);
    }
}

int SocketForLog::write_n(const void* data, size_t size) {
    int bytes_left = size;
    int written_bytes = 0;
    const char* ptr = reinterpret_cast<const char*>(data);
    while(bytes_left > 0) {
        written_bytes = ::write(_socket_fd, ptr, bytes_left);
        if(written_bytes <= 0) {       
            if(errno == EINTR) {
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

char DataSrtream::kSplitCharFlag = '\n';

DataSrtream::DataSrtream(size_t init_size, std::function<void(const void*, size_t)> call_back) :
        _size(init_size),
        _call_back(call_back) {
    _data = new int8_t[_size]; 
}

DataSrtream::~DataSrtream() {
    if (nullptr != _data) {
        delete[] _data;
    }
}


bool DataSrtream::write(const void* data, size_t size) {
    std::lock_guard<std::mutex> lk(_mutex);
    if (size > _size - _writed_size -1) {
      _can_be_read = true;
      return false; 
    }
    memcpy(_data + _writed_size, data, size);
    _writed_size += size;
    return true;
}

bool DataSrtream::read() {
    std::lock_guard<std::mutex> lk(_mutex);
    if (!_can_be_read || _call_back == nullptr) {
      return false;
    }
    _call_back(_data, _writed_size);
    _writed_size = 0;
    return true;
}

size_t LogClientStream::kDataStreamVectorMaxSize = 20;
size_t LogClientStream::kDataStreamInitSize = 1024;

static SocketForLog sockt_sink;
LogClientStream& LogClientStream::get_instance() {
    static LogClientStream log_client_stream([](const void* data, size_t size) {
                sockt_sink.write(data, size);
            });
    return log_client_stream;
}

void LogClientStream::run_thread(void* handle) {
    static_cast<LogClientStream*>(handle)->run();
}

LogClientStream::LogClientStream(std::function<void(const void*, size_t)> call_back) : _call_back(call_back) {
    _is_stop = false;
    constexpr size_t kInitSize = 10; 
    for(size_t i = 0; i < kInitSize; ++i) {
       _data_stream_vector.push_back(
               std::unique_ptr<DataSrtream>(new DataSrtream(kDataStreamInitSize, _call_back))); 
    }
    _thread_t = std::thread(run_thread, this);
}

LogClientStream::~LogClientStream() {
    _is_stop = true;
    _thread_t.join();
}

void LogClientStream::run() {
    while(!_is_stop) {
        bool is_read = false;
        sockt_sink.try_connect();
        DataSrtream* ptr = nullptr;
        {
            std::lock_guard<std::mutex> lk(_mutex);
            ptr = _data_stream_vector[_cur_read_index].get();
        }
        is_read = ptr->read();
        if (is_read) {
            std::lock_guard<std::mutex> lk(_mutex);
            _cur_read_index = (_cur_read_index + 1) % _data_stream_vector.size();
        } else {
            std::this_thread::sleep_for(std::chrono::milliseconds(20));
        }
    }
}

void LogClientStream::resize_vector_and_write(const void* data, size_t size) {
    std::lock_guard<std::mutex> lk(_mutex);
    printf("ztx_test resize_vector_and_write start: %zu\n", _data_stream_vector.size());
    const size_t cur_vec_size = _data_stream_vector.size();
    size_t new_size = std::max(cur_vec_size * 3 / 2, kDataStreamVectorMaxSize);
    auto tmp_vector = std::vector<std::unique_ptr<DataSrtream>>(new_size);
    size_t cur_index = _cur_read_index;
    size_t tmp_index = 0;
    for (; tmp_index < cur_vec_size; ++tmp_index) {
        cur_index = (_cur_read_index + tmp_index) % cur_vec_size;
        tmp_vector[tmp_index] = std::move(_data_stream_vector[cur_index]);
    }
    for (; tmp_index < tmp_vector.size(); ++tmp_index) {
        tmp_vector[tmp_index] = 
            std::unique_ptr<DataSrtream>(new DataSrtream(kDataStreamInitSize, _call_back));
    }
    std::swap(_data_stream_vector, tmp_vector);
    _data_stream_vector[cur_vec_size]->write(data, size);
    _cur_read_index = 0;
    _cur_write_index = cur_vec_size;
    printf("ztx_test resize_vector_and_write end: %zu\n", _data_stream_vector.size());
}

void LogClientStream::write(const void *data, size_t size) {
    bool has_writed = false;
    for (size_t index = 0; index < 2; ++index) {
        if (_data_stream_vector[_cur_write_index]->write(data, size)) {
            has_writed = true;
            break;
        } else {
            _cur_write_index = (_cur_write_index + 1) % _data_stream_vector.size();
        }
    }

    if (!has_writed && _data_stream_vector.size() < kDataStreamVectorMaxSize) {
        resize_vector_and_write(data, size);
    }
}

struct MyKeyHashHasher
{
	size_t operator()(const LogLevel& level) const noexcept
	{
		return static_cast<size_t>(level);
	}
};

const std::unordered_map<LogLevel, const char*, MyKeyHashHasher> kLogLeveToString = {
    {LogLevel::kDebug, "DEBUG: "},
    {LogLevel::kInfo, "INFO: "},
    {LogLevel::kWarnning, "WARN: "},
    {LogLevel::kError, "ERROR: "}
};

LogStream::LogStream(LogLevel log_level, const char* tag, LogClientStream& log_client_stream) :
        _log_client_stream(log_client_stream) {
   _stream << kLogLeveToString.find(log_level)->second << tag << ": ";
}
} // plot_plot
