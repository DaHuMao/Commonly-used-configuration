#include <algorithm>
#include "base/array_list.h"
#include <iostream>

void Check(const ArrayList<int>& list, const std::vector<int>& vec) {
  CHECK_EQ(list.size(), vec.size());
  auto it = list.begin();
  auto vec_it = vec.begin();
  for (; it != list.end(); ++it, ++vec_it) {
    std::cout << *it << ":" << *vec_it << " ";
  }
  std::cout << std::endl;
  it = list.begin();
  vec_it = vec.begin();
  for (; it != list.end(); ++it, ++vec_it) {
    CHECK_EQ(*it, *vec_it);
  }
  auto rit = list.rbegin();
  auto rvec_it = vec.rbegin();
  for (; rit != list.rend(); ++rit, ++rvec_it) {
    CHECK_EQ(*rit, *rvec_it);
  }
}

int main() {
  ArrayList<int> list;
  std::vector<int> vec = {1, 2, 3, 4, 5};
  for (int i : vec) {
    list.push_back(i);
  }
  Check(list, vec);
  auto it = std::find(list.begin(), list.end(), 3);
  it = list.insert(it, 6);
  CHECK_EQ(*it, 6);
  Check(list, {1, 2,  3, 6, 4, 5});
  it = std::find(list.begin(), list.end(), 4);
  it = list.erase(it);
  CHECK_EQ(*it, 5);
  Check(list, {1, 2, 3, 6, 5});
  list.pop_back();
  Check(list, {1, 2, 3, 6});
  list.push_front(0);
  Check(list, {0, 1, 2, 3, 6});
  list.pop_front();
  Check(list, {1, 2, 3, 6});
  it = std::find(list.begin(), list.end(), 3);
  list.move_to_front(it);
  Check(list, {3, 1, 2, 6});
  list.move_to_back(it);
  Check(list, {1, 2, 6, 3});
  auto it2 =  std::find(list.begin(), list.end(), 2);
  list.move_after(it2, it);
  Check(list, {1, 6, 3, 2});
  CHECK_EQ(*list.begin(), 1);
  CHECK_EQ(*list.back(), 2);
  CHECK_EQ(list.size(), 4);
  list.move_before(it2, it);
  Check(list, {1, 6, 2, 3});
  it = list.insert_previous(list.begin(), 0);
  CHECK_EQ(*it, 0);
  Check(list, {0, 1, 6, 2, 3});
  it = list.insert_previous(list.back(), 4);
  CHECK_EQ(*it, 4);
  Check(list, {0, 1, 6, 2, 4, 3});
  list.clear();
  CHECK_EQ(list.size(), 0);
  CHECK(list.empty());
  return 0;
}
