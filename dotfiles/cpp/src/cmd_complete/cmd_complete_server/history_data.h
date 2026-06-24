#include <cstdint>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#include "base/interval_dict_tree.h"
struct HistoryDataConfig {
  uint16_t max_history_data_size = 50000;
  uint16_t max_terminal_history_data_size = 2000;
  // 一次查询最大的历史命令数量
  uint16_t max_query_size = 10;
  // 线程查询间隔时间
  uint16_t sleep_interval_seconds = 20 * 60;

  // 达到多长时间强行写文件
  uint16_t force_write_file_seconds = 60 * 60 * 4;

  // insert 数据量达到多少时，写入文件
  uint16_t write_file_min_count = max_terminal_history_data_size / 5;

  int64_t history_process_dead_seconds = 60 * 60 * 24 * 7;
  std::string history_data_file = "";

  HistoryDataConfig(uint16_t max_history_data_size,
                    uint16_t max_terminal_history_data_size)
      : max_history_data_size(max_history_data_size),
        max_terminal_history_data_size(max_terminal_history_data_size) {
    write_file_min_count = max_terminal_history_data_size / 5;
  }
  bool Check() const {
    return max_history_data_size > 0 && max_terminal_history_data_size > 0 &&
      write_file_min_count < max_terminal_history_data_size;
  }
  std::string ToString() const;
};
class HistoryData final {
 public:
  HistoryData(const HistoryDataConfig &config);
  ~HistoryData();
  std::vector<std::string> GetHistoryDataArray(int pid,
                                               const char* data, size_t size);
  std::string GetHistoryData(int pid, const char* data, size_t size);
  void InsertData(int pid, const char *data, size_t size);
  std::vector<std::string> GetHistoryDataArray(int pid, std::string_view data) {
    return GetHistoryDataArray(pid, data.data(), data.size());
  }
  std::string GetHistoryData(int pid, std::string_view data) {
    return GetHistoryData(pid, data.data(), data.size());
  }
  void InsertData(int pid, std::string_view data) {
    InsertData(pid, data.data(), data.size());
  }
  void Exit(int pid);

  std::string ToStr() const;

  const IntervalDictTree<uint16_t> *GetIntervalDictTree(int pid) {
    std::lock_guard<std::mutex> lock(mutex_);
    if (pid == -1) {
      return &interval_dict_tree_base_;
    }
    auto it = interval_dict_tree_map_.find(pid);
    if (it != interval_dict_tree_map_.end()) {
      return it->second.tree.get();
    }
    return nullptr;
  }

 private:
  struct TerminalInfo {
    int64_t has_no_update_time_seconds = 0;
    std::unique_ptr<IntervalDictTree<uint16_t>> tree;
  };

  void InitBaseMap(const std::string &file);
  void WriteDataToFile();
  void ThreadRun();
  static void ThreadFunc(HistoryData *history_data);

 private:
  const HistoryDataConfig config_;
  // 每个终端对应一个IntervalDictTree吗，用进程ID作为key
  std::unordered_map<int, TerminalInfo> interval_dict_tree_map_;
  // 存储所有的历史命令记录，所有终端的历史命令会定期合并到这个IntervalDictTree中
  IntervalDictTree<uint16_t> interval_dict_tree_base_;
  std::thread thread_;
  bool is_exit_ = false;
  bool is_update_ = false;
  uint32_t insert_count_all_ = 0;
  uint32_t last_write_file_time_wait_ = 0;
  std::mutex mutex_;
  std::condition_variable cv_;
};
