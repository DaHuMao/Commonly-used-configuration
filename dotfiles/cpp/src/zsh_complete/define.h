#ifndef SRC_ZSH_COMPLETE_DEFINE_H_
#define SRC_ZSH_COMPLETE_DEFINE_H_
#include <string>
#define BUFFER_MAX_SIZE 2048
#define COMMAND_MAX_SIZE 48
#define MIN_INSERT_STR_SIZE 5
#define MAX_SUGGESTION_SIZE 10


// command
#define COMMAND_EXIT 1
#define COMMAND_INSERT 2
#define COMMAND_QUERY 3
#define COMMAND_QUERYARRAY 4
#define COMMAND_TERMINAL_EXIT 5


#define HISTORY_MAX_SIZE 50000
#define HISTORY_MAX_TERMINAL_SIZE 2000
#define HISTORY_MAX_QUERY_SIZE 10
#define HISTORY_SLEEP_INTERVAL_SECONDS 1 * 60
#define HISTORY_FORCE_WRITE_FILE_SECONDS 60 * 60 * 4
#define HISTORY_PROCESS_DEAD_SECONDS 60 * 60 * 24

std::string GetHistoryFile();
std::string GetLogFile();
std::string GetCacheFile();
std::string GetS2CFifoFile();
std::string GetC2SFifoFile();
std::string GetSocketClientBaseName();
std::string GetSocketServerBaseName();
#endif  // SRC_ZSH_COMPLETE_DEFINE_H_
