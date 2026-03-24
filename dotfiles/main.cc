#include <functional>
#include <iostream>
#include <queue>
#include <sstream>
#include <string>
#include <set>
#include <string_view>

struct test {
  std::string prifix;
  std::string suffix;
  bool operator<(const test& rhs) const {
    return prifix < rhs.prifix || (prifix == rhs.prifix && suffix.size() < rhs.suffix.size());
  }
  bool operator==(const test& rhs) const {
    return prifix == rhs.prifix && suffix == rhs.suffix;
  }
};

int main() {
  const char* buf = "11 2 bb";
  std::string_view str(buf, 8);
  int space1 = str.find(' ');
  int space2 = str.find(' ', space1 + 1);
  std::stringstream ss;
  int val1 = -1, val2 = -1;
  std::string str3;
  ss << str;
  ss >> val1 >> val2 >> str3;
  std::cout << val1 << " " << val2 << " " << str3 << std::endl;
}

