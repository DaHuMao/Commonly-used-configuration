#ifndef SRC_ARRAY_LIST_H_
#define SRC_ARRAY_LIST_H_
#include <algorithm>
#include <vector>

#include "check.h"

template <typename T, typename IndexType = uint16_t>
class ArrayList {
  static_assert(std::is_unsigned_v<IndexType>,
                "IndexType must be integral type");
  static constexpr const char* kTag = "ArrayList";

 private:
  struct Node {
    Node() = default;
    Node(const T& value) : value(value) {}
    Node(T&& value) : value(std::move(value)) {}
    T value;
    IndexType prev = 0;
    IndexType next = 0;
  };

 public:
  template <bool is_const, bool is_reverse>
  class iterator_internal {
    typedef typename std::conditional<is_const, const std::vector<Node>,
                                      std::vector<Node>>::type array_type;
    typedef typename std::conditional<is_const, const T, T>::type value_type;
    friend class ArrayList;

   public:
    iterator_internal() = default;
    iterator_internal(array_type& data, IndexType index)
        : data_(&data), index_(index) {
      CHECK_LT(index_, data_->size());
      CHECK_GE(index_, 0);
    }
    iterator_internal(iterator_internal&& other) noexcept
        : data_(other.data_), index_(other.index_) {
      other.set_null();
    }
    iterator_internal(const iterator_internal& other)
        : data_(other.data_), index_(other.index_) {}
    iterator_internal& operator=(const iterator_internal& other) {
      data_ = other.data_;
      index_ = other.index_;
      return *this;
    }
    iterator_internal& operator=(iterator_internal&& other) noexcept {
      if (this == &other) {
        return *this;
      }
      data_ = other.data_;
      index_ = other.index_;
      other.index_ = 0;
      other.data_ = nullptr;
      return *this;
    }
    value_type& operator*() const {
      CHECK_LT(index_, data_->size());
      CHECK_GT(index_, 0);
      return (*data_)[index_].value;
    }

    value_type* operator->() const {
      CHECK_LT(index_, data_->size());
      CHECK_GT(index_, 0);
      return &(*data_)[index_].value;
    }

    iterator_internal& operator++() {
      CHECK_NE(index_, 0);
      if (is_reverse) {
        index_ = (*data_)[index_].prev;
      } else {
        index_ = (*data_)[index_].next;
      }
      return *this;
    }
    iterator_internal operator++(int) {
      CHECK_NE(index_, 0);
      iterator_internal tmp = *this;
      if (is_reverse) {
        index_ = (*data_)[index_].prev;
      } else {
        index_ = (*data_)[index_].next;
      }
      return tmp;
    }
    iterator_internal& operator--() {
      CHECK_NE(index_, 1);
      if (is_reverse) {
        index_ = (*data_)[index_].next;
      } else {
        index_ = (*data_)[index_].prev;
      }
      return *this;
    }
    iterator_internal operator--(int) {
      CHECK_NE(index_, 1);
      iterator_internal tmp = *this;
      if (is_reverse) {
        index_ = (*data_)[index_].next;
      } else {
        index_ = (*data_)[index_].prev;
      }
      return tmp;
    }
    bool operator!=(const iterator_internal& other) const {
      CHECK_EQ(data_, other.data_);
      return index_ != other.index_;
    }
    bool operator==(const iterator_internal& other) const {
      CHECK_EQ(data_, other.data_);
      return index_ == other.index_;
    }
    bool is_null() const { return data_ == nullptr; }

    void set_null() {
      data_ = nullptr;
      index_ = 0;
    }

   private:
    array_type* data_ = nullptr;
    IndexType index_ = 0;
  };

 public:
  typedef iterator_internal<false, false> iterator;
  typedef iterator_internal<true, false> const_iterator;
  typedef iterator_internal<false, true> reverse_iterator;
  typedef iterator_internal<true, true> const_reverse_iterator;
  ArrayList(IndexType init_capacity = 0) {
    init_capacity += 1;
    CHECK_LT(init_capacity, std::numeric_limits<IndexType>::max());
    data_.reserve(init_capacity);
    data_.emplace_back();
    data_[0].next = 0;
    data_[0].prev = 0;
  }
  ~ArrayList() = default;

  ArrayList(const ArrayList& other) {
    data_ = other.data_;
    free_list_ = other.free_list_;
  }

  ArrayList& operator=(const ArrayList& other) {
    data_ = other.data_;
    free_list_ = other.free_list_;
    return *this;
  }

  ArrayList(ArrayList&& other) noexcept {
    data_ = std::move(other.data_);
    free_list_ = std::move(other.free_list_);
  }

  ArrayList& operator=(ArrayList&& other) noexcept {
    if (this == &other) {
      return *this;
    }
    data_ = std::move(other.data_);
    free_list_ = std::move(other.free_list_);
    return *this;
  }
  iterator begin() { return iterator(data_, data_[0].next); }

  iterator end() { return iterator(data_, 0); }

  iterator back() { return iterator(data_, data_[0].prev); }

  const_iterator begin() const { return const_iterator(data_, data_[0].next); }

  const_iterator end() const { return const_iterator(data_, 0); }

  const_iterator back() const { return const_iterator(data_, data_[0].prev); }

  const_iterator cbegin() const { return begin(); }

  const_iterator cend() const { return end(); }

  const_iterator cback() const { return const_iterator(data_, data_[0].prev); }

  reverse_iterator rbegin() { return reverse_iterator(data_, data_[0].prev); }

  reverse_iterator rend() { return reverse_iterator(data_, 0); }

  const_reverse_iterator rbegin() const {
    return const_reverse_iterator(data_, data_[0].prev);
  }

  const_reverse_iterator rend() const {
    return const_reverse_iterator(data_, 0);
  }

  const_reverse_iterator crbegin() const {
    return const_reverse_iterator(data_, data_[0].prev);
  }

  const_reverse_iterator crend() const {
    return const_reverse_iterator(data_, 0);
  }

  iterator insert(iterator pos, T&& value) {
    if (free_list_.empty()) {
      CHECK_LT(data_.size(), std::numeric_limits<IndexType>::max());
      data_.emplace_back();
      free_list_.push_back(data_.size() - 1);
    }
    IndexType index = free_list_.back();
    free_list_.pop_back();
    data_[index].value = std::move(value);
    combine_node(pos.index_, index, data_[pos.index_].next);
    return iterator(data_, index);
  }

  iterator insert(iterator pos, const T& value) {
    return insert(pos, T(value));
  }

  iterator insert_previous(iterator pos, T&& value) {
    return insert(iterator(data_, data_[pos.index_].prev), std::move(value));
  }

  iterator insert_previous(iterator pos, const T& value) {
    return insert(iterator(data_, data_[pos.index_].prev), value);
  }

  iterator move_after(iterator pos, iterator after_this_pos) {
    CHECK_NE(pos.index_, 0);
    CHECK_NE(after_this_pos.index_, 0);
    if (pos.index_ == after_this_pos.index_ ||
        pos.index_ == data_[after_this_pos.index_].next) {
      return pos;
    }
    combine_node(data_[pos.index_].prev, data_[pos.index_].next);
    combine_node(after_this_pos.index_, pos.index_,
                 data_[after_this_pos.index_].next);
    return iterator(data_, pos.index_);
  }

  iterator move_before(iterator pos, iterator before_this_pos) {
    CHECK_NE(pos.index_, 0);
    CHECK_NE(before_this_pos.index_, 0);
    if (pos.index_ == before_this_pos.index_ ||
        pos.index_ == data_[before_this_pos.index_].prev) {
      return pos;
    }
    combine_node(data_[pos.index_].prev, data_[pos.index_].next);
    combine_node(data_[before_this_pos.index_].prev, pos.index_,
                 before_this_pos.index_);
    return iterator(data_, pos.index_);
  }

  iterator move_to_back(iterator pos) { return move_after(pos, back()); }

  iterator move_to_front(iterator pos) { return move_before(pos, begin()); }

  iterator erase(iterator pos) {
    CHECK_NE(pos.index_, 0);
    IndexType next_node = data_[pos.index_].next;
    IndexType prev_node = data_[pos.index_].prev;
    data_[pos.index_].next = 0;
    data_[pos.index_].prev = 0;
    free_list_.push_back(pos.index_);
    combine_node(prev_node, next_node);
    return iterator(data_, next_node);
  }

  iterator push_back(T&& value) { return insert(back(), std::move(value)); }

  iterator push_back(const T& value) { return insert(back(), value); }

  void pop_back() { erase(back()); }

  iterator push_front(T&& value) { return insert(end(), std::move(value)); }

  iterator push_front(const T& value) { return insert(end(), value); }

  void pop_front() { erase(begin()); }

  bool empty() const { return data_[0].next == 0; }

  size_t size() const { return data_.size() - free_list_.size() - 1; }

  void clear() {
    data_.clear();
    free_list_.clear();
    data_.emplace_back();
    data_[0].next = 0;
    data_[0].prev = 0;
  }

 private:
  void combine_node(IndexType first_node, IndexType second_node) {
    data_[first_node].next = second_node;
    data_[second_node].prev = first_node;
  }

  void combine_node(IndexType first_node, IndexType second_node,
                    IndexType third_node) {
    combine_node(first_node, second_node);
    combine_node(second_node, third_node);
  }
  std::vector<Node> data_;
  std::vector<IndexType> free_list_;
};
#endif  // SRC_ARRAY_LIST_H_
