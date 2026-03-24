#include "util.h"
#include <cstdlib>
#include "base/log.h"

#if defined(UNIX_LIKE_PLATFORM)
#include <sys/types.h>
#include <signal.h>
#include <errno.h>
#elif defined(WIN_PLATFORM)
#include <windows.h>
#include <shlobj.h>
#endif

namespace util {
int64_t GetTimeNowMs() {
  auto now = std::chrono::system_clock::now();
  return std::chrono::duration_cast<std::chrono::milliseconds>(
             now.time_since_epoch())
      .count();
}
std::string GetTimeNow(const std::string& format) {
  auto now = std::chrono::system_clock::now();
  auto now_time_t = std::chrono::system_clock::to_time_t(now);
  auto now_tm = *std::localtime(&now_time_t);
  char time_str[100] = {0};
  std::strftime(time_str, sizeof(time_str), format.c_str(), &now_tm);
  return time_str;
}

bool ProcessIsAlive(int pid) {
#if defined(IS_IN_TEST)
  return true;
#elif defined(UNIX_LIKE_PLATFORM)
  return (kill(pid, 0) == 0 || errno == EPERM);
#elif defined(WIN_PLATFORM)
  HANDLE process = OpenProcess(SYNCHRONIZE, FALSE, pid);
  if (process == NULL) {
    return false;
  }

  DWORD returnCode = WaitForSingleObject(process, 0);
  CloseHandle(process);
   return returnCode == WAIT_TIMEOUT;
#else
  static_assert(false, "Unsupported platform");
#endif
}

// 去除字符串中首空格
// 如果有连续两个空格，只保留一个
ssize_t StripSpace(char* ptr, ssize_t size) {
  ssize_t write_index = 0, read_index = 0;
  while (read_index < size) {
    if (ptr[read_index] == ' ') {
      if (write_index > 0 && ptr[write_index - 1] != ' ') {
        ptr[write_index++] = ptr[read_index++];
      } else {
        ++read_index;
      }
    } else {
      ptr[write_index++] = ptr[read_index++];
    }
  }
  /*if (write_index > 0 && ptr[write_index - 1] == ' ') {
    --write_index;
  }*/
  return write_index;
}
size_t StrIsMatchPrefix(const char* str1, size_t size1, const char* str2,
                        size_t size2) {
  size_t size = size1;
  if (size > size2) {
    size = size2;
  }
  size_t i = 0;
  for (; i < size; ++i) {
    if (str1[i] != str2[i]) {
      break;
    }
  }
  return i;
}

size_t StrIsMatchPrefix(const std::string& str1, const std::string& str2) {
  return StrIsMatchPrefix(str1.data(), str1.size(), str2.data(), str2.size());
}

size_t StrIsMatchPrefix(std::string_view str1, std::string_view str2) {
  return StrIsMatchPrefix(str1.data(), str1.size(), str2.data(), str2.size());
}
#if defined(UNIX_LIKE_PLATFORM)
std::string GetHomeDir() {
  const char* homeDir = std::getenv("HOME");
  if (homeDir == nullptr) {
    LOG_E("GetHomeDir") << "Failed to get HOME environment variable";
    return "";
  }
  return std::string(homeDir);
}
#elif defined(WIN_PLATFORM)
std::string GetHomeDir() {
  char path[MAX_PATH];
  if (SUCCEEDED(SHGetFolderPathA(NULL, CSIDL_PROFILE, NULL, 0, path))) {
    return std::string(path);
  } else {
    LOG_E("GetHomeDir") << "Failed to get home directory";
    return "";
  }
}
#endif
}  // namespace util
