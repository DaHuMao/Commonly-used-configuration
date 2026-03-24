#ifndef TEST_TEST_UTIL_H_
#define TEST_TEST_UTIL_H_
#include <ostream>
#include <sstream>
#include <string>
std::string GenaerateRandomString(int size);

template <typename T>
std::string VecToStr(const std::vector<T>& vec) {
  std::stringstream ss;
  for (auto& ee : vec) {
    ss << ee << ", ";
  }
  ss << std::endl;
  return ss.str();
}
#endif // TEST_TEST_UTIL_H_
