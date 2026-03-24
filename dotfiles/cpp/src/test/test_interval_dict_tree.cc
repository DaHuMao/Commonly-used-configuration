#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

#include "base/interval_dict_tree.h"
#include "base/dict_tree_base_map.h"
#include "base/util.h"
#include "test/test_util.h"

std::vector<StrInfo> vec_g;

std::string VecStrInfoToStr(const std::vector<StrInfo>& vec) {
  std::stringstream ss;
  for (auto& ee : vec) {
    ss << "\"" << ee.key << "\"" << ", ";
  }
  ss << std::endl;
  return ss.str();
}

std::string MapToStr(const std::map<std::string, int>* m) {
  if (m == nullptr) {
    return "";
  }
  std::stringstream ss;
  ss << "m.size(): " << m->size() << std::endl;
  for (const auto& ele : *m) {
    ss << ele.first << ":" << ele.second << " ";
  }
  ss << std::endl;
  return ss.str();
}


std::string ToStr(const std::vector<std::string> res,
                  const std::vector<std::string>& vec,
                  const DictTreeBaseMap* ps,
                  const IntervalDictTree<uint16_t>& tree) {
  auto ps_str = ps == nullptr ? "" : ps->ToStr();
  return "res: " + VecToStr(res) + "vec: " + VecToStr(vec) +
         "\ninsertvec: " + VecStrInfoToStr(vec_g) + "\nset: " + ps_str +
         "\nlist: " + tree.ToStrForList() + "\ntree: " + tree.ToStrForTree();
}

template <typename IndexType>
void Check(const IntervalDictTree<IndexType>& tree, const std::string& prefix,
           const std::vector<std::string> vec,
                  const DictTreeBaseMap* ps = nullptr) {
  tree.CheckSelf();
  std::vector<std::string> res = tree.QueryArrayPrefix(prefix);
  CHECK_EQ(res.size(), vec.size()) << "prefix: " << prefix << " \n"
                                   << ToStr(res, vec, ps, tree);

  if (res.empty()) {
    return;
  }
  CHECK_EQ(tree.QueryPrefix(prefix), vec.back())
      << "prefix: " << prefix << " \n"
      << ToStr(res, vec, ps, tree);
  for (size_t i = 0; i < vec.size(); ++i) {
    CHECK_EQ(res[i], vec[vec.size() - i - 1]) << "prefix: " << prefix << " \n"
                                              << ToStr(res, vec, ps, tree);
  }
}

void test_tree_functionality() {
  IntervalDictTree<uint16_t> tree(11, 4);
  std::vector<std::string> data = {"ab",    "abc",   "bcd",   "abcd",
                                   "bcdef", "cdefg", "defgh", "efghi",
                                   "fghij", "ghijk", "hijkl"};
  for (const std::string& str : data) {
    tree.Insert(str);
  }
  Check(tree, "a", {"ab", "abc", "abcd"});
  Check(tree, "ab", {"abc", "abcd"});
  Check(tree, "abc", {"abcd"});
  Check(tree, "abcd", {});
  Check(tree, "bc", {"bcd", "bcdef"});
  Check(tree, "bcde", {"bcdef"});
  Check(tree, "c", {"cdefg"});
  Check(tree, "def", {"defgh"});
  Check(tree, "efg", {"efghi"});
  Check(tree, "fgh", {"fghij"});
  Check(tree, "ghi", {"ghijk"});
  Check(tree, "hij", {"hijkl"});
  tree.Insert("def");
  Check(tree, "de", {"defgh", "def"});
  Check(tree, "ab", {"abc", "abcd"});
  tree.Insert("defg");
  Check(tree, "de", {"defgh", "def", "defg"});
  tree.Insert("defghtt");
  Check(tree, "de", {"defgh", "def", "defg", "defghtt"});
  tree.Insert("defghttg");
  Check(tree, "de", {"def", "defg", "defghtt", "defghttg"});
  Check(tree, "a", {});
  tree.Insert("d");
  Check(tree, "d", {"defg", "defghtt", "defghttg"});
}

void TestTest() {
  // jq jzmfm jjx jrbd jf jyj jn jmp jxk
  // jq jzmfm jxk jjx jrbd jf jyj jn jmp
  std::vector<std::string> vec = {
  };
  constexpr int max_str_size = 1000;
  constexpr int max_query_size = 10;
  int num = 0;
  IntervalDictTree<uint16_t> tree(max_str_size, max_query_size);
  for (const auto& str : vec) {
    ++num;
    if (str == "t") {
      std::cout << "breakpoint" << " " << num<< std::endl;
    }
    tree.Insert(str);
  }
  std::cout << tree.ToStrForTree() << std::endl;
}

void RandomTest() {
  std::srand(std::time(0));
  constexpr int max_str_size = 1000;
  constexpr int max_query_size = 10;
  IntervalDictTree<uint16_t> tree(max_str_size, max_query_size);
  DictTreeBaseMap test_tree(max_str_size, max_query_size);
  constexpr int test_num = 10000;
  int muti_num = 0;
  for (int i = 0; i < test_num; ++i) {
    std::string str = GenaerateRandomString(6);
    vec_g.push_back({str, static_cast<uint64_t>(i)});
    std::cout << "i: " << i
      << " tree size: " << tree.Size()
      << " map size: " << test_tree.Size()
      << " muti_num: " << test_tree.MutiNum()
      << std::endl;
    tree.Insert(str);
    test_tree.Insert(str);
    auto prefix = GenaerateRandomString(6);
    auto vec = test_tree.QueryPrefix(prefix);
    Check(tree, prefix, vec, &test_tree);
  }
}

void PerformanceTest() {
  std::srand(std::time(0));
  constexpr int kTestCount = 100000;
  constexpr int kMaxStrSize = 100;
  constexpr int kMaxDataSize = 50000;
  constexpr int kMaxQueryStrSize = 40;
  constexpr int kMaxQuerySize = 60;
  std::vector<std::pair<std::string, std::string>> v;
  v.reserve(kTestCount);
  for(int i = 0; i < kTestCount; ++i) {
    v.push_back(
        {GenaerateRandomString(kMaxStrSize),
        GenaerateRandomString(kMaxQueryStrSize)});
  }

  IntervalDictTree<unsigned int> tree(kMaxDataSize, kMaxQueryStrSize);
  DictTreeBaseMap test_tree(kMaxDataSize, kMaxQueryStrSize);

  auto st = util::GetTimeNowMs();
  size_t test_size = 0;
  for(auto& ele : v) {
    tree.Insert(ele.first);
    auto vec = tree.QueryArrayPrefix(ele.second);
    test_size += vec.size();
  }
  std::cout << "tree used time: " << util::GetTimeNowMs() - st << std::endl;

  st = util::GetTimeNowMs();
  int num = 0;
  for(auto& ele : v) {
    test_tree.Insert(ele.first);
    auto vec = test_tree.QueryPrefix(ele.second);
    test_size += vec.size();
  }

  std::cout << "map used time: " << util::GetTimeNowMs() - st << std::endl;
  std::cout << "test_size: " << test_size << std::endl;

}

int main() {
  test_tree_functionality();
  RandomTest();
  PerformanceTest();
  return 0;
}
