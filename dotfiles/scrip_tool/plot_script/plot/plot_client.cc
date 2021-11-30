#include "plot_client.h"
#include <cstdarg>
#include <unordered_map>

#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>

class SocketForLog {
public:
    SocketForLog();
    ~SocketForLog();
    void write(const void* data, size_t size);
private:
    int write_n(const void* data, size_t size);
    int _socket_fd = -1;
};

SocketForLog::SocketForLog() {
    const char* ip_address = "127.0.0.1";
    int ip_port = 9600;
    _socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (_socket_fd < 0) {
        return;
    }
    struct sockaddr_in t_sockaddr;
    memset(&t_sockaddr, 0, sizeof(struct sockaddr_in));
    t_sockaddr.sin_family = AF_INET;
    t_sockaddr.sin_port = htons(ip_port);
    inet_pton(AF_INET, ip_address, &t_sockaddr.sin_addr);
    if((connect(_socket_fd, (struct sockaddr*)&t_sockaddr, sizeof(struct sockaddr))) < 0 ) {
        close(_socket_fd);
    }
}

SocketForLog::~SocketForLog() {
    if (_socket_fd > 0) {
        close(_socket_fd);
        _socket_fd = -1;
    }
}

void SocketForLog::write(const void *data, size_t size) {
    if(write_n(data, size) < 0) {
        fprintf(stderr, "send message error: %s errno : %d", strerror(errno), errno);
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
size_t LogClientStream::kDataStreamInitSize = 200;

LogClientStream& LogClientStream::get_instance() {
    static SocketForLog sockt_sink;
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
    for(size_t i = 0; i < 10; ++i) {
       _data_stream_vector.push_back(
               std::make_unique<DataSrtream>(kDataStreamInitSize, _call_back)); 
    }
    _thread_t = std::thread(run_thread, this);
}

LogClientStream::~LogClientStream() {
    _is_stop = true;
    _thread_t.join();
}

void LogClientStream::run() {
    while(!_is_stop) {
        std::lock_guard<std::mutex> lk(_mutex);
        if (_data_stream_vector[_cur_read_index]->read()) {
            _cur_read_index = (_cur_read_index + 1) % _data_stream_vector.size();
        } else {
            std::this_thread::sleep_for(std::chrono::milliseconds(20));
        }
    }
}

void LogClientStream::resize_vector_and_write(const void* data, size_t size) {
    std::lock_guard<std::mutex> lk(_mutex);
    printf("resize_vector_and_write: %d\n", _data_stream_vector.size());
    const size_t cur_vec_size = _data_stream_vector.size();
    size_t new_size = std::max(cur_vec_size * 3 / 2, kDataStreamVectorMaxSize);
    auto tmp_vector = std::vector<std::unique_ptr<DataSrtream>>(new_size);
    size_t cur_index = _cur_read_index;
    size_t tmp_index = 0;
    for (; tmp_index < cur_vec_size; ++tmp_index) {
        tmp_vector[tmp_index] = std::move(_data_stream_vector[cur_index]);
        cur_index = (_cur_read_index + tmp_index) % cur_vec_size;
    }
    for (; tmp_index < tmp_vector.size(); ++tmp_index) {
        tmp_vector[tmp_index] = std::make_unique<DataSrtream>(kDataStreamInitSize, _call_back);
    }
    std::swap(_data_stream_vector, tmp_vector);
    _data_stream_vector[cur_vec_size]->write(data, size);
    _cur_read_index = 0;
    _cur_write_index = cur_vec_size;
    printf("resize_vector_and_write: %d\n", _data_stream_vector.size());
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

const std::unordered_map<LogLevel, const char*> kLogLeveToString = {
    {LogLevel::kDebug, "DEBUG: "},
    {LogLevel::kInfo, "INFO: "},
    {LogLevel::kWarnning, "WARN: "},
    {LogLevel::kError, "ERROR: "}
};

LogStream::LogStream(LogLevel log_level, const char* tag, LogClientStream& log_client_stream) :
        _log_client_stream(log_client_stream) {
   _stream << kLogLeveToString.find(log_level)->second << tag << ": ";
}

//************************example***********************************
/*
int main() {
    const size_t count = 1000;
    const size_t max_val = 50;
    int val = 0;
    int flag = 1;
    for (size_t i = 0; i < count; ++i) {
        LOGI("media_info") << "send_speak_count:" << val << " "
                     << "aec_speak_count:" << val + 1 << " "
                     << "sssadsa" << " "
                     << "RTT:" << val + 3 << " "
                     << "send_speak_energy:" << val + 10 << " ";
        LOGI("test") << "ssssssdfsad";
        if (val <= 0) {
            flag = 1;
        } else if (val >= max_val) {
            flag = -1;
        }
        val += flag;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
}
*/
