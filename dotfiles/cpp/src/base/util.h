#ifndef UTIL_H_
#define UTIL_H_
#include <cstdint>
#include <string>
#include <sys/_types/_ssize_t.h>
namespace util {
int64_t GetTimeNowMs();
std::string GetTimeNow(const std::string& format = "%H:%M");
ssize_t StripSpace(char* ptr, ssize_t size);
size_t StrIsMatchPrefix(const char* str1, size_t size1, const char* str2, size_t size2);
size_t StrIsMatchPrefix(const std::string& str1, const std::string& str2);
size_t StrIsMatchPrefix(std::string_view str1, std::string_view str2);
bool ProcessIsAlive(int pid);
std::string GetHomeDir();
} // namespace util
#endif // UTIL_H_
