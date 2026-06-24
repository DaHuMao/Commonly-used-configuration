#include "history_data.h"

#include <fstream>
#include <string>

#include "base/check.h"
#include "base/log.h"
std::string HistoryDataConfig::ToString() const {
  std::stringstream ss;
  ss << "max_history_data_size: " << max_history_data_size
     << " max_terminal_history_data_size: "
     << max_terminal_history_data_size
     << " write_file_min_count: " << write_file_min_count
     << " sleep_interval_seconds: " << sleep_interval_seconds
     << " force_write_file_seconds: " << force_write_file_seconds
     << " history_process_dead_seconds: "
     << history_process_dead_seconds;
  return ss.str();
}

constexpr const char* kTag = "HistoryData";
HistoryData::HistoryData(const HistoryDataConfig& config)
    : config_(config),
      interval_dict_tree_base_(config_.max_history_data_size,
                               config_.max_query_size) {
  InitBaseMap(config_.history_data_file);
  thread_ = std::thread(ThreadFunc, this);
  if (!thread_.joinable()) {
    LOG_E(kTag) << "create thread failed";
  }

  LOG_I(kTag) << "config_: " << config_.ToString();
  if (!config_.Check()) {
    CHECK(false);
  }
}

HistoryData::~HistoryData() {
  {
    std::lock_guard<std::mutex> lock(mutex_);
    is_exit_ = true;
    cv_.notify_all();
  }
  if (thread_.joinable()) {
    thread_.join();
  }
  LOG_I(kTag) << "WriteDataToFile size: " << interval_dict_tree_base_.Size();
  WriteDataToFile();
}

std::vector<std::string> HistoryData::GetHistoryDataArray(
    int pid, const char* data, size_t size) {
  std::lock_guard<std::mutex> lock(mutex_);
  is_update_ = true;
  std::vector<std::string> res;
  auto it = interval_dict_tree_map_.find(pid);
  if (it != interval_dict_tree_map_.end()) {
    res = it->second.tree->QueryArrayPrefix(data);
    it->second.has_no_update_time_seconds = 0;
  }
  if (res.size() < config_.max_query_size) {
    auto res_base = interval_dict_tree_base_.QueryArrayPrefix(
        std::string(data, size));
    for (const auto& str : res_base) {
      if (res.size() >= config_.max_query_size) {
        break;
      }
      if (std::find(res.begin(), res.end(), str) == res.end()) {
        res.push_back(str);
      }
    }
  }
  return res;
}

std::string HistoryData::GetHistoryData(int pid, const char* data, size_t size) {
  std::lock_guard<std::mutex> lock(mutex_);
  is_update_ = true;
  auto it = interval_dict_tree_map_.find(pid);
  if (it != interval_dict_tree_map_.end()) {
    std::string str = it->second.tree->QueryPrefix(std::string(data, size));
    it->second.has_no_update_time_seconds = 0;
    if (str.empty()) {
      str = interval_dict_tree_base_.QueryPrefix(std::string(data, size));
    }
    return str;
  } else {
    return interval_dict_tree_base_.QueryPrefix(std::string(data, size));
  }
}

void HistoryData::InsertData(int pid, const char* data, size_t size) {
  std::lock_guard<std::mutex> lock(mutex_);
  is_update_ = true;
  ++insert_count_all_;
  auto it = interval_dict_tree_map_.find(pid);
  if (it == interval_dict_tree_map_.end()) {
    LOG_I(kTag) << "create tree with pid: " << pid;
    it = interval_dict_tree_map_.insert({pid, TerminalInfo()}).first;
    it->second.tree = std::make_unique<IntervalDictTree<uint16_t>>(
        config_.max_terminal_history_data_size, config_.max_query_size);
  }
  it->second.tree->Insert(std::string(data, size));
  it->second.has_no_update_time_seconds = 0;
  interval_dict_tree_base_.Insert(std::string(data, size));
}

void HistoryData::Exit(int pid) {
  std::lock_guard<std::mutex> lock(mutex_);
  auto it = interval_dict_tree_map_.find(pid);
  if (it != interval_dict_tree_map_.end()) {
    interval_dict_tree_map_.erase(it);
    LOG_I(kTag) << "exit pid: " << pid
      << " current map size: " << interval_dict_tree_map_.size();
  } else {
    LOG_W(kTag) << "exit pid: " << pid << " not found";
  }
}

std::string HistoryData::ToStr() const {
  std::stringstream ss;
  ss << "interval_dict_tree_map_: " << std::endl;
  for (const auto& ele : interval_dict_tree_map_) {
    ss << "pid: " << ele.first << " " << ele.second.tree->ToStrForTree()
       << std::endl;
  }
  ss << "interval_dict_tree_base_: " << interval_dict_tree_base_.ToStrForTree()
     << std::endl;
  return ss.str();
}

void HistoryData::InitBaseMap(const std::string& file) {
  std::ifstream out(file);
  std::string str;
  while (std::getline(out, str)) {
    interval_dict_tree_base_.Insert(str);
  }
  LOG_I(kTag) << "init base map size: " << interval_dict_tree_base_.Size();
  return;
}

void HistoryData::WriteDataToFile() {
  std::string data_file = config_.history_data_file + ".tmp";
  auto data = interval_dict_tree_base_.Data();
  std::ofstream in(data_file, std::ios::trunc);
  for (const auto& str : data) {
    in << str << std::endl;
  }
  in.close();
  if (std::rename(data_file.c_str(), config_.history_data_file.c_str()) != 0) {
    LOG_E(kTag) << "rename file: " << data_file << " to "
                << config_.history_data_file << " failed";
  }
}

void HistoryData::ThreadRun() {
  const int kMergeMinCount = config_.max_terminal_history_data_size / 2;
  const int kWriteFileMinCount = config_.max_history_data_size / 5;
  while (!is_exit_) {
    std::unique_lock<std::mutex> lock(mutex_);
    if (is_exit_) {
      return;
    }
    cv_.wait_for(lock, std::chrono::seconds(config_.sleep_interval_seconds));
    last_write_file_time_wait_ += config_.sleep_interval_seconds;
    if (!is_update_) {
      if (insert_count_all_ > kWriteFileMinCount ||
          (last_write_file_time_wait_ > config_.force_write_file_seconds &&
           insert_count_all_ > 0)) {
        LOG_I(kTag) << "write file insert_count_all_: " << insert_count_all_;
        WriteDataToFile();
        insert_count_all_ = 0;
      }
    }
    auto it = interval_dict_tree_map_.begin();
    while (it != interval_dict_tree_map_.end()) {
      it->second.has_no_update_time_seconds += config_.sleep_interval_seconds;
      if (it->second.has_no_update_time_seconds >=
          config_.history_process_dead_seconds) {
        LOG_I(kTag) << "process with pid: " << it->first
          << " has no update time: " << it->second.has_no_update_time_seconds
          << " remove it";
        it = interval_dict_tree_map_.erase(it);
        if (it == interval_dict_tree_map_.end()) {
          break;
        }
      }

      ++it;
    }
    is_update_ = false;
  }
  return;
}

void HistoryData::ThreadFunc(HistoryData* history_data) {
  history_data->ThreadRun();
}
