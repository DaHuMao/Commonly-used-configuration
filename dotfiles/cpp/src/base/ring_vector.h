#ifndef SRC_RING_VECTOR_H_
#define SRC_RING_VECTOR_H_
#include <algorithm>
#include <cassert>
#include <cstddef>
#include <vector>

#include "log.h"

template <typename T>
class RingVector final {
static constexpr const char* kTag = "RingVector";
 public:
  friend class Iterator;
  class Iterator {
   public:
    Iterator(RingVector* ring, size_t index);
    T& operator*();
    Iterator& operator++();
    Iterator operator++(int);
    Iterator& operator--();
    Iterator operator--(int);
    bool operator!=(const Iterator& other) const {
      assert(ring_ == other.ring_);
      return index_ != other.index_;
    }
    bool operator==(const Iterator& other) const {
      assert(ring_ == other.ring_);
      return index_ == other.index_;
    }
   private:
    void CheckInvalidValue(bool is_reverse);
    RingVector* ring_;
    size_t index_;
  };
 public:
  explicit RingVector(size_t max_size,
                      bool force_init_capacity = false,
                      bool remove_duplicate_element_ = false,
                      T default_invalid_value = T()) :
    max_size_(remove_duplicate_element_ ? max_size * 2 : max_size),
    remove_duplicate_element_(remove_duplicate_element_),
    default_invalid_value_(default_invalid_value){
    if (force_init_capacity) {
      data_.reserve(max_size_);
    }
  }
  ~RingVector() = default;
  RingVector(const RingVector&) = delete;
  RingVector& operator=(const RingVector&) = delete;
  RingVector(RingVector&&) = delete;
  RingVector& operator=(RingVector&&) = delete;
  typename RingVector<T>::Iterator begin() {
    return Iterator(this, 0);
  }
  typename RingVector<T>::Iterator end() {
    return Iterator(this, data_.size());
  }
  void PushBack(const T& t);
  void PushBack(T&& t);
 private:
  std::vector<T> data_;
  size_t start_pos_ = 0;
  const size_t max_size_ = 0;
  bool remove_duplicate_element_ = false;
  T default_invalid_value_;

};

template <typename T>
void RingVector<T>::PushBack(const T& t) {
  auto tmp = t;
  PushBack(std::move(tmp));
}

template <typename T>
void RingVector<T>::PushBack(T&& t) {
  if (remove_duplicate_element_) {
    auto it = std::find(data_.begin(), data_.end(), t);
    if (it != data_.end()) {
      *it = default_invalid_value_;
    }
  }
  if (data_.size() < max_size_) {
    data_.emplace_back(std::move(t));
  } else {
    data_[start_pos_] = std::move(t);
    start_pos_ = (start_pos_ + 1) % max_size_;
  }
}

template <typename T>
RingVector<T>::Iterator::Iterator(RingVector* ring, size_t index)
  : ring_(ring), index_(index) {
  if (ring_->remove_duplicate_element_ && index_ == ring_->data_.size()) {
  }
}

template <typename T>
T& RingVector<T>::Iterator::operator*() {
  return ring_->data_[(ring_->start_pos_ + index_) % ring_->max_size_];
}

template <typename T>
typename RingVector<T>::Iterator& RingVector<T>::Iterator::operator++() {
  ++index_;
  if (index_ > ring_->data_.size()) {
    LOG_F(kTag) << "invalid index_:" << index_
      << " ring_->size_:" << ring_->data_.size();
  }
  CheckInvalidValue(false);
  return *this;
}

template <typename T>
typename RingVector<T>::Iterator RingVector<T>::Iterator::operator++(int) {
  Iterator tmp = *this;
  ++index_;
  if (index_ > ring_->data_.size()) {
    LOG_F(kTag) << "invalid index_:" << index_
      << " ring_->size_:" << ring_->data_.size();
  }
  CheckInvalidValue(false);
  return tmp;
}

template <typename T>
typename RingVector<T>::Iterator& RingVector<T>::Iterator::operator--() {
  --index_;
  if (index_ < 0) {
    LOG_F(kTag) << "invalid index_:" << index_;
  }
  CheckInvalidValue(true);
  return *this;
}

template <typename T>
typename RingVector<T>::Iterator RingVector<T>::Iterator::operator--(int) {
  Iterator tmp = *this;
  --index_;
  if (index_ < 0) {
    LOG_F(kTag) << "invalid index_:" << index_;
  }
  CheckInvalidValue(true);
  return tmp;
}

template <typename T>
void RingVector<T>::Iterator::CheckInvalidValue(bool is_reverse) {
  int flag = is_reverse ? -1 : 1;
  int end = is_reverse ? 0 : ring_->data_.size();
  if (ring_->remove_duplicate_element_) {
    while (index_ != end &&
           *(*this) == ring_->default_invalid_value_) {
      index_ += flag;
    }
  }
}




#endif // SRC_RING_VECTOR_H_
