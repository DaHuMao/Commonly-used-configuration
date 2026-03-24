#ifndef SRC_INTERVAL_DICT_TREE_H_
#define SRC_INTERVAL_DICT_TREE_H_
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <strstream>
#include <type_traits>

#include "base/array_list.h"
#include "base/util.h"

template <typename IndexType, typename QueryArrSizeType = uint8_t>
class IntervalDictTree {
  static_assert(std::is_unsigned_v<IndexType>,
                "IndexType must be integral type");
  static_assert(std::is_unsigned_v<QueryArrSizeType>,
                "QueryArrSizeType must be integral type");

  typedef typename ArrayList<std::string, IndexType>::iterator iterator;

 private:
  struct Node {
    iterator data_index_;
    ArrayList<iterator, QueryArrSizeType> index_array;
    std::map<std::string, Node> children;
    typedef typename std::map<std::string, Node>::iterator map_iterator;
    typedef
        typename std::map<std::string, Node>::const_iterator const_map_iterator;
    void UpdateIndexArray(iterator index, QueryArrSizeType query_arr_size) {
      auto find_it = std::find(index_array.begin(), index_array.end(), index);
      if (find_it != index_array.end()) {
        index_array.move_to_back(find_it);
      } else {
        if (index_array.size() >= query_arr_size) {
          index_array.pop_front();
        }
        index_array.push_back(index);
      }
    }

    template <typename MapType>
    static auto FindMatchHelper(MapType& children, const std::string& sv)
        -> std::pair<decltype(children.begin()), size_t>
    {
        if (children.empty()) {
            return {children.end(), 0};
        }
        auto it = children.lower_bound(sv);
        size_t match_size = 0;
        if (it != children.end()) {
            match_size = util::StrIsMatchPrefix(sv, it->first);
        }
        if (match_size == 0 && it != children.begin()) {
            --it;
            match_size = util::StrIsMatchPrefix(sv, it->first);
        }
        return {it, match_size};
    }

    std::pair<map_iterator, size_t> FindMatch(const std::string& sv) {
      return FindMatchHelper(children, sv);
    }

    std::pair<const_map_iterator, size_t> FindMatch(
        const std::string& sv) const {
      return FindMatchHelper(children, sv);
    }

    void CheckErase(const iterator& it_index) {
      auto it = std::find(index_array.begin(), index_array.end(), it_index);
      if (it != index_array.end()) {
        index_array.erase(it);
      }
    }

    void CheckMerge(typename std::map<std::string, Node>::iterator& it) {
      if (it->second.data_index_.is_null()) {
        if (it->second.children.size() == 1) {
          auto& pair_it = *it->second.children.begin();
          children.insert(
              {it->first + pair_it.first, std::move(pair_it.second)});
        }
        if (it->second.children.size() < 2) {
          children.erase(it);
        }
      }
    }
  };

 public:
  IntervalDictTree(IndexType max_size, QueryArrSizeType query_arr_size = 10)
      : max_size_(max_size), query_arr_size_(query_arr_size), data_(max_size) {
    CHECK_GT(max_size - 1, query_arr_size)
        << "invalid max_size: " << max_size
        << " query_arr_size: " << query_arr_size;
  }
  ~IntervalDictTree() = default;
  void Insert(const std::string& data) {
    if (data.empty()) {
      return;
    }
    cur_data_ = &data;
    iterator index_result;
    InsertNodeInternal(root_, 0, index_result);
    CHECK_EQ(data, *index_result);
    if (data_.size() > max_size_) {
      std::pair<std::string, Node> node_pair;
      index_result.set_null();
      EraseNodeInternal(root_, *data_.begin(), 0, index_result);
      data_.pop_front();
    }
  }

  std::string QueryPrefix(const std::string& prefix) const {
    const ArrayList<iterator, QueryArrSizeType>* array = nullptr;
    QueryPrefixInternal(root_, prefix, 0, &array);
    if (nullptr == array) {
      return "";
    }
    CHECK(!array->empty()) << "prefix: " << prefix;
    auto it = array->rbegin();
    if (**it == prefix) {
      ++it;
    }
    return it == array->rend() ? "" : **it;
  }

  std::vector<std::string> QueryArrayPrefix(const std::string& prefix) const {
    const ArrayList<iterator, QueryArrSizeType>* array = nullptr;
    QueryPrefixInternal(root_, prefix, 0, &array);
    if (nullptr == array) {
      return {};
    }
    std::vector<std::string> res;
    auto it = array->rbegin();
    for (; it != array->rend(); ++it) {
      if (**it == prefix) {
        continue;
      }
      res.push_back(**it);
    }
    return res;
  }

  size_t Size() const { return data_.size(); }

  const ArrayList<std::string, IndexType>& Data() const { return data_; }

  std::string ToStrForTree() const {
    std::stringstream ss;
    PrintInternal(ss, root_, "");
    return ss.str();
  }

  std::string ToStrForList() const {
    std::stringstream ss;
    ss << "[ ";
    for (auto& ele : data_) {
      ss << "\"" << ele << "\", ";
    }
    ss << "]";
    return ss.str();
  }

  void CheckSelf() const { CheckSelf(root_, ""); }

 private:
  void CheckSelf(const Node& node, const std::string& prefix) const {
    if (!node.data_index_.is_null()) {
      auto it = std::find(data_.begin(), data_.end(), *node.data_index_);
      if (it == data_.end()) {
        CHECK(false) << *node.data_index_ << " not found in data_"
                     << "list: " << ToStrForList() << "\n"
                     << ToStrForTree();
      }
    }
    if (node.children.empty()) {
      CHECK(!node.data_index_.is_null())
          << "key: " << prefix << " has no data_index_"
          << " \nlist: " << ToStrForList() << "\n"
          << ToStrForTree();
    }
    for (const auto& index : node.index_array) {
      auto it = std::find(data_.begin(), data_.end(), *index);
      CHECK(it != data_.end()) << *index << " not found in data_"
                               << "list: " << ToStrForList() << "\n"
                               << ToStrForTree();
    }
    for (const auto& [key, child] : node.children) {
      if (!child.data_index_.is_null()) {
        auto it = std::find(data_.begin(), data_.end(), prefix + key);
        if (it == data_.end()) {
          CHECK(false) << prefix + key << " not found in data_"
                       << "list: " << ToStrForList() << "\n"
                       << ToStrForTree();
        }
      }
      CheckSelf(child, prefix + key);
    }
  }
  void PrintInternal(std::stringstream& ss, const Node& node,
                     const std::string& workspace) const {
    for (const auto& [key, child] : node.children) {
      ss << std::endl;
      ss << workspace + key << " is key: " << !child.data_index_.is_null()
         << " child size: " << child.children.size() << " index_array: ";
      for (auto& index : child.index_array) {
        ss << *index << " ";
      }
      if (!child.children.empty()) {
        ss << std::endl;
        ss << workspace + "{";
        PrintInternal(ss, child, workspace + "  ");
        ss << std::endl;
        ss << workspace + "}";
      }
    }
  }
  void InsertNodeInternal(Node& node, int start_pos, iterator& index_result);
  bool EraseNodeInternal(Node& node, const std::string& str, int start_pos,
                         iterator& index_result);
  void QueryPrefixInternal(
      const Node& node, const std::string& prefix, int start_pos,
      const ArrayList<iterator, QueryArrSizeType>** ptr_array) const;

 private:
  const std::string* cur_data_ = nullptr;
  Node root_;
  IndexType max_size_;
  QueryArrSizeType query_arr_size_;
  ArrayList<std::string, IndexType> data_;
};

template <typename IndexType, typename QueryArrSizeType>
void IntervalDictTree<IndexType, QueryArrSizeType>::InsertNodeInternal(
    IntervalDictTree<IndexType, QueryArrSizeType>::Node& node, int start_pos,
    iterator& index_result) {
  CHECK_LT(start_pos, cur_data_->size());
  std::string sv(cur_data_->data() + start_pos, cur_data_->size() - start_pos);
  auto [it, match_size] = node.FindMatch(sv);
  IntervalDictTree<IndexType, QueryArrSizeType>::Node* next_node = nullptr;
  bool is_find = match_size == sv.size() || match_size == 0;
  if (match_size == 0) {
    next_node = &node.children[sv];
  } else if (match_size == it->first.size()) {
    next_node = &it->second;
  } else {
    std::string key_father(sv.data(), match_size);
    std::string key_child_it(it->first.data() + match_size,
                             it->first.size() - match_size);
    auto& new_node_father = node.children[std::move(key_father)];
    new_node_father.index_array = it->second.index_array;
    new_node_father.children[std::move(key_child_it)] = std::move(it->second);
    node.children.erase(it);

    if (!is_find) {
      new_node_father.children[std::string(sv.data() + match_size,
                                           sv.size() - match_size)] = Node();
    }
    next_node = &new_node_father;
  }
  if (is_find) {
    if (next_node->data_index_.is_null()) {
      index_result = data_.push_back(*cur_data_);
      next_node->data_index_ = index_result;
    } else {
      index_result = next_node->data_index_;
      data_.move_to_back(index_result);
    }
    next_node->UpdateIndexArray(index_result, query_arr_size_);
  } else {
    InsertNodeInternal(*next_node, start_pos + match_size, index_result);
  }
  node.UpdateIndexArray(index_result, query_arr_size_);
}

template <typename IndexType, typename QueryArrSizeType>
void IntervalDictTree<IndexType, QueryArrSizeType>::QueryPrefixInternal(
    const typename IntervalDictTree<IndexType, QueryArrSizeType>::Node& node,
    const std::string& prefix, int start_pos,
    const ArrayList<typename ArrayList<std::string, IndexType>::iterator,
                    QueryArrSizeType>** ptr_array) const {
  CHECK_LT(start_pos, prefix.size());
  std::string sv(prefix.data() + start_pos, prefix.size() - start_pos);
  auto [it, match_size] = node.FindMatch(sv);
  if (match_size == 0) {
    return;
  }
  if (match_size == sv.size()) {
    *ptr_array = &it->second.index_array;
  } else if (match_size == it->first.size()) {
    CHECK_LT(match_size, sv.size());
    QueryPrefixInternal(it->second, prefix, start_pos + match_size, ptr_array);
  }
  return;
}

template <typename IndexType, typename QueryArrSizeType>
bool IntervalDictTree<IndexType, QueryArrSizeType>::EraseNodeInternal(
    typename IntervalDictTree<IndexType, QueryArrSizeType>::Node& node,
    const std::string& str, int start_pos, iterator& index_result) {
  CHECK_LT(start_pos, str.size());
  bool is_find = false;
  bool should_check = false;
  std::string sv(str.data() + start_pos, str.size() - start_pos);
  auto [it, match_size] = node.FindMatch(sv);
  CHECK(it != node.children.end());
  if (match_size == sv.size()) {
    CHECK(!it->second.data_index_.is_null());
    index_result = it->second.data_index_;
    it->second.CheckErase(index_result);
    it->second.data_index_.set_null();
    is_find = true;
    should_check = true;
    if (it->second.children.size() == 1) {
      auto& pair_it = *it->second.children.begin();
      node.children.insert({sv + pair_it.first, std::move(pair_it.second)});
    }
  } else if (match_size == it->first.size()) {
    CHECK_LT(match_size, sv.size());
    should_check = EraseNodeInternal(it->second, str, start_pos + match_size,
                                     index_result);
  } else {
    CHECK(false) << "should not be here";
  }
  if (should_check) {
    node.CheckMerge(it);
    should_check = is_find;
  }

  if (!index_result.is_null()) {
    node.CheckErase(index_result);
  }
  return should_check;
}

#endif  // SRC_INTERVAL_DICT_TREE_H_
