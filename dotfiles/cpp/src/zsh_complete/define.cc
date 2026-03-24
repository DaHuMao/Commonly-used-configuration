#include "define.h"
#define S2C_FIFO_FILE "server_to_client_fifo"
#define C2S_FIFO_FILE "client_to_server_fifo"
#define LOG_FILE_FILE "myzsh.log"
#define HISTORY_FILE_FILE "history_data.txt"

#ifdef CUSTOM_ZSH_HISTORY_FILE
constexpr const char* kCustomZshHistoryFile = CUSTOM_ZSH_HISTORY_FILE;
#endif // #ifdef CUSTOM_ZSH_HISTORY_FILE

#ifdef ZSH_CACHE_DIR
constexpr const char* kZshCacheDir = ZSH_CACHE_DIR;
#else
constexpr const char* kZshCacheDir = "";
static_assert(false, "ZSH_CACHE_DIR is not defined");
#endif // #ifdef ZSH_CACHE_DIR

#ifdef ZSH_FIFO_DIR
constexpr const char* kZshFifoDir = ZSH_FIFO_DIR;
#else
constexpr const char* kZshFifoDir = "";
#endif // #ifdef ZSH_FIFO_DIR

#ifdef ZSH_SOCKET_DIR
constexpr const char* kZshSocketDir = ZSH_SOCKET_DIR;
#else
constexpr const char* kZshSocketDir = "";
static_assert(false, "ZSH_SOCKET_DIR is not defined");
#endif // #ifdef ZSH_SOCKET_DIR

std::string GetHistoryFile() {
  auto history_file = std::getenv("CUSTOM_ZSH_HISTORY_FILE");
  if (history_file != nullptr) {
    return std::string(history_file);
  }
  auto cache_dir = GetCacheFile();
  if (cache_dir.empty()) {
    return std::string();
  }
  return std::string(cache_dir) + "/" + HISTORY_FILE_FILE;
}

std::string GetLogFile() {
  auto cache_dir = GetCacheFile();
  if (cache_dir.empty()) {
    return std::string();
  }
  return std::string(cache_dir) + "/" + LOG_FILE_FILE;
}

std::string GetCacheFile() {
  auto cache_dir = kZshCacheDir;
  if (cache_dir == nullptr) {
    return std::string();
  }
  return std::string(cache_dir);
}

std::string GetS2CFifoFile() {
  auto fifo_dir = kZshFifoDir;
  if (fifo_dir == nullptr) {
    return std::string();
  }
  return std::string(fifo_dir) + "/" + S2C_FIFO_FILE;
}

std::string GetC2SFifoFile() {
  auto fifo_dir = kZshFifoDir;
  if (fifo_dir == nullptr) {
    return std::string();
  }
  return std::string(fifo_dir) + "/" + C2S_FIFO_FILE;
}

std::string GetSocketClientBaseName() {
  auto socket_dir = kZshSocketDir;
  if (socket_dir == nullptr) {
    return std::string();
  }
  return std::string(socket_dir) + "/zsh_complete_client";
}

std::string GetSocketServerBaseName() {
  auto socket_dir = kZshSocketDir;
  if (socket_dir == nullptr) {
    return std::string();
  }
  return std::string(socket_dir) + "/zsh_complete_server";
}
