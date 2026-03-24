#include <deque>
#include <fstream>
#include <iostream>
#include <sstream>
#include <vector>

#include "./zsh_complete/zsh_complete_server/history_data.h"
#include "base/log.h"
#include "base/util.h"
#include "test/test_util.h"

constexpr const char* kHistroyFile = "./history_data.txt";
std::ofstream log_file("./log.txt");

void log_callback(const std::string& log) {
  log_file << util::GetTimeNow("%Y-%m-%d %H:%M:%S") << " " << log << std::endl;
}

void flush_callback() { log_file.flush(); }

struct TestHistoryDataInfo {
  std::string str;
  int pid = -1;
  int count = 0;
};

struct TestStrInfo {
  std::string key;
  uint64_t count = 0;
  bool operator==(const TestStrInfo& other) const { return key == other.key; }
};

std::ostream& operator<<(std::ostream& os, const TestStrInfo& info) {
  os << info.key << ":" << info.count;
  return os;
}

constexpr int kMaxHistoryDataSize = 10000;
constexpr int kMaxTerminalHistoryDataSize = 2000;
constexpr int kMaxQuerySize = 10;
constexpr int kSleepIntervalSeconds = 1;
ArrayList<TestStrInfo> vec_g(kMaxHistoryDataSize);
std::vector<ArrayList<TestStrInfo>> vec_g_vec(
    3, ArrayList<TestStrInfo>(kMaxTerminalHistoryDataSize));

std::string ArrayListToStr(const ArrayList<TestStrInfo>& vec) {
  std::stringstream ss;
  for (const auto& ele : vec) {
    ss << ele.key << " ";
  }
  return ss.str();
}

std::string AllToStr(const std::vector<TestStrInfo>& res1,
    const std::vector<std::string>& res2, int index) {
  std::stringstream ss;
  ss << "pid: " << index <<"\nres1:\n " << VecToStr(res1) << "res2:\n " << VecToStr(res2)
    << "\nvec_g_vec:\n" << ArrayListToStr(vec_g_vec[index])
    << "\nvec_g:\n" << ArrayListToStr(vec_g);
  return ss.str();
}

void TestFile() {
  std::ifstream file(kHistroyFile);
  std::string line;
  int index = 0;
  auto it = vec_g.begin();
  while (std::getline(file, line)) {
    ++index;
    if (it == vec_g.end()) {
      CHECK(false) << "index: " << index << "line: " << line;
    }
    CHECK_EQ(line, it->key)
        << "index: " << index << "line: " << line << "vec_g:\n"
        << ArrayListToStr(vec_g);
    ++it;
  }
  CHECK_EQ(index, vec_g.size()) << "index: " << index << "vec_g:\n"
                                << ArrayListToStr(vec_g);
}

std::vector<TestStrInfo> GetStringArray(const std::string& query,
                                        const ArrayList<TestStrInfo>& vec,
                                        int count) {
  std::vector<TestStrInfo> res;
  for (auto it = vec.rbegin(); it != vec.rend(); ++it) {
    auto ele = *it;
    if (ele.key.substr(0, query.size()) == query) {
      if (res.size() >= count) {
        break;
      }
      res.push_back(ele);
    }
  }
  auto it = std::find(res.begin(), res.end(), TestStrInfo{query, 0});
  if (it != res.end()) {
    res.erase(it);
  }
  std::vector<TestStrInfo> res1;
  for (auto it = vec_g.rbegin(); it != vec_g.rend(); ++it) {
    auto ele = *it;
    if (ele.key.substr(0, query.size()) == query) {
      if (res1.size() >= count) {
        break;
      }
      res1.push_back(ele);
    }
  }
  it = std::find(res1.begin(), res1.end(), TestStrInfo{query, 0});
  if (it != res1.end()) {
    res1.erase(it);
  }
  for (auto& ele : res1) {
    if (res.size() >= count) {
      break;
    }
    if (std::find(res.begin(), res.end(), ele) == res.end()) {
      res.push_back(ele);
    }
  }
  return res;
}


void TestQuery(HistoryData& history_data) {
  auto query_str = GenaerateRandomString(6);
  for (int i = 0; i < vec_g_vec.size(); ++i) {
    auto res1 = GetStringArray(query_str, vec_g_vec[i], kMaxQuerySize);
    auto res2 = history_data.GetHistoryDataArray(i, query_str);
    CHECK_EQ(res1.size(), res2.size()) << "\nquery_str: " << query_str
      << AllToStr(res1, res2, i)
      << "\n history_data: \n"
      << "\n pid_tree \n" << history_data.GetIntervalDictTree(i)->ToStrForTree()
      << "\n base_tree \n" << history_data.GetIntervalDictTree(-1)->ToStrForTree()
      << "\ni \n" << VecToStr(history_data.GetIntervalDictTree(i)->QueryArrayPrefix(query_str))
      << "\nbase: \n" << VecToStr(history_data.GetIntervalDictTree(-1)->QueryArrayPrefix(query_str));
    for (int i = 0; i < res1.size(); ++i) {
      CHECK_EQ(res2[i], res1[i].key) << "\nquery_str: " << query_str
        << AllToStr(res1, res2, i)
        << "\n history_data: \n"
        << history_data.ToStr();
    }
  }
}

void Test() {
  uint64_t count = 0;
  HistoryDataConfig config(kMaxHistoryDataSize, kMaxTerminalHistoryDataSize);
  config.max_query_size = kMaxQuerySize;
  config.sleep_interval_seconds = kSleepIntervalSeconds;
  config.history_data_file = kHistroyFile;
  config.force_write_file_seconds = kSleepIntervalSeconds + 1;
  HistoryData history_data(config);
  constexpr int kTestCount = 50000;
  while (count < kTestCount) {
    TestStrInfo ele = {GenaerateRandomString(200), count};
    auto it = std::find(vec_g.begin(), vec_g.end(), ele);
    if (it != vec_g.end()) {
      vec_g.erase(it);
    }
    vec_g.push_back(ele);
    if (vec_g.size() > config.max_history_data_size) {
      vec_g.pop_front();
    }
    ++count;
    int index = std::rand() % vec_g_vec.size();
    history_data.InsertData(index, ele.key);
    auto& vec = vec_g_vec[index];
    it = std::find(vec.begin(), vec.end(), ele);
    if (it != vec.end()) {
      vec.erase(it);
    }
    vec.push_back(ele);
    if (vec.size() > config.max_terminal_history_data_size) {
      vec.pop_front();
    }
    std::cout << "ele: " << ele << std::endl;
    std::cout << "count: " << count << " vec_g size: " << vec_g.size();
    for (int i = 0; i < vec_g_vec.size(); ++i) {
      std::cout << " vec_g_vec index " << " " << i << " size: " << vec_g_vec[i].size();
    }
    std::cout << std::endl;
    TestQuery(history_data);
    if (std::rand() % 2000 == 5) {
      std::this_thread::sleep_for(std::chrono::seconds(
            kSleepIntervalSeconds * 3));
      TestFile();
    }
  }
}

int main() {
  LogStream::SetLogLevel(LogLevel::kInfo);
  LogStream::SetLogCallBack({log_callback, flush_callback});
  Test();
  return 0;
}
