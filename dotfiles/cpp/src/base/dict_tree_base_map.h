#ifndef SRC_DICT_TREE_BASE_MAP_H_
#define SRC_DICT_TREE_BASE_MAP_H_
#include <list>
#include <map>
#include <ostream>
#include <sstream>
struct StrInfo {
  std::string key;
  uint64_t number = 0;
  bool operator<(const StrInfo& other) const { return key < other.key; }
};
class DictTreeBaseMap {
struct TreeInfo;
using ListIter = std::list<std::map<std::string, TreeInfo>::iterator>::iterator;
struct TreeInfo {
  uint64_t num = 0;
  ListIter it;
};
public:
  DictTreeBaseMap(int max_size, int max_query_size)
      : max_size_(max_size), max_query_size_(max_query_size) {}
  void Insert(const std::string& str) {
    ++num_;
    auto it_find = m_.find(str);
    if (it_find != m_.end()) {
      ++muti_num_;
      it_find->second.num = num_;
      list_.erase(it_find->second.it);
      it_find->second.it = list_.insert(list_.end(), it_find);
      return;
    }
    auto [it, is_insert] = m_.insert({str, {num_, list_.end()}});

    it->second.it = list_.insert(list_.end(), it);
    if (m_.size() > max_size_) {
      m_.erase(list_.front());
      list_.pop_front();
    }
  }
  std::vector<std::string> QueryPrefix(const std::string& prefix,
      bool is_reverse = true) {
    std::vector<std::string> res;
    std::vector<StrInfo> vec;
    auto it = m_.lower_bound({prefix, 0});
    while (it != m_.end() && it->first.find(prefix) == 0) {
      vec.push_back({it->first, it->second.num});
      ++it;
    }
    std::sort(vec.begin(), vec.end(), [](const StrInfo& l, const StrInfo& r) {
        return l.number > r.number;
        });
    if (vec.size() > max_query_size_) {
      vec.resize(max_query_size_);
    }
    if (is_reverse) {
      for (auto it = vec.rbegin(); it != vec.rend(); ++it) {
        if (it->key == prefix) {
          continue;
        }
        res.push_back(it->key);
      }
    } else {
      for (auto it = vec.begin(); it != vec.end(); ++it) {
        if (it->key == prefix) {
          continue;
        }
        res.push_back(it->key);
      }
    }
    return res;
  }

  int MutiNum() const {
    return muti_num_;
  }

  int Size() const {
    return m_.size();
  }

  std::string ToStr() const {
    std::stringstream ss;
    for (const auto& ele : m_) {
      ss << ele.first << ":" << ele.second.num << " ";
    }
    ss << std::endl;
    return ss.str();
  }

private:
  std::map<std::string, TreeInfo> m_;
  std::list<std::map<std::string, TreeInfo>::iterator> list_;
  uint64_t num_ = 0;
  int muti_num_ = 0;
  int max_size_ = 0;
  int max_query_size_ = 0;
};
#endif // SRC_DICT_TREE_BASE_MAP_H_
