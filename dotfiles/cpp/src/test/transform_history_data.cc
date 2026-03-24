
#include <fstream>
#include <string>
#include <iostream>
#include <set>
int main(int argc, char* argv[]) {
  std::set<std::string> s;
  std::string in_file = argv[1];
  std::string out_file = argv[2];
  std::ofstream out(out_file);
  std::ifstream in(in_file);
  while (in) {
    std::string line;
    std::getline(in, line);
    auto pos = line.find_first_of(";");
    //std::cout << line << " " << pos << " " << line.size() << std::endl;
    if (pos < 0 || pos + 1 >= line.size()) {
      continue;
    }
    std::string str = line.substr(pos + 1, line.size());
    if (str.size() > 8 && s.find(str) == s.end()){
      s.insert(str);
      out << str << std::endl;
    }
  }
}
