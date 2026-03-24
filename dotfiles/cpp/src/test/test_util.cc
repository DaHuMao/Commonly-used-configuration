#include "test/test_util.h"
#include <random>
#include <ctime>
// 1. 创建一个随机数生成器（这里我们使用 Mersenne Twister 引擎 `std::mt19937`）
static std::mt19937 generator;

// 2. 设定种子值（这里使用当前时间作为种子）
static std::uint32_t seed = static_cast<std::uint32_t>(std::time(nullptr));
std::string GenaerateRandomString(int size) {
  generator.seed(seed);
  std::uniform_int_distribution<int> distribution(0, 25);
  std::string res;
  for (int i = 0; i < size; ++i) {
    res.push_back('a' + distribution(generator));
  }
  return res;
}
