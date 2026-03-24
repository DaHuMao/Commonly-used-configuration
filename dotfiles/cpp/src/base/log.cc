#include "log.h"
#include <cstdlib>
#include <iostream>
#include <chrono>
#include <iomanip>
#include <ctime>

void default_log_callback(const std::string &log) {
  std::cerr << log;
}

void default_flush_callback() {
  std::cerr.flush();
}

static LogLevel g_log_level = LogLevel::kDebug;
static LogCallBack g_log_call_back = {default_log_callback,
  default_flush_callback};

std::string LogLevelToString(LogLevel log_level) {
  switch (log_level) {
    case LogLevel::kDebug:
      return "DEBUG";
    case LogLevel::kInfo:
      return "INFO";
    case LogLevel::kWarnning:
      return "WARNNING";
    case LogLevel::kError:
      return "ERROR";
    case LogLevel::kFatal:
      return "FATAL";
    default:
      return "UNKNOWN";
  }
}

void LogStream::SetLogLevel(LogLevel log_level) {
  g_log_level = log_level;
}

void LogStream::SetLogCallBack(const LogCallBack &log_call_back) {
  g_log_call_back = log_call_back;
}

 LogStream::LogStream(LogLevel log_level,
     const char* file, int line, const char *tag)
  : log_level_(log_level) {
  if (log_level_ < g_log_level) {
    return;
  }

  // 添加时间信息 (月-日 时:分:秒)
  auto now = std::chrono::system_clock::now();
  auto time_t_now = std::chrono::system_clock::to_time_t(now);
  std::tm tm_now;
  localtime_r(&time_t_now, &tm_now);

  stream_ << std::setfill('0')
          << std::setw(2) << (tm_now.tm_mon + 1) << "-"
          << std::setw(2) << tm_now.tm_mday << " "
          << std::setw(2) << tm_now.tm_hour << ":"
          << std::setw(2) << tm_now.tm_min << ":"
          << std::setw(2) << tm_now.tm_sec << " ";

  if (log_level == LogLevel::kFatal || log_level == LogLevel::kError) {
    stream_ << " file " << file << " line " << line << " ";
  }
  stream_ << "[" << LogLevelToString(log_level) << "] " << tag << ": ";
}

LogStream::~LogStream() {
  if (log_level_ < g_log_level) {
    return;
  }
  stream_ << std::endl;
  if (g_log_call_back.call_back) {
    g_log_call_back.call_back(stream_.str());
  }
  if (log_level_ == LogLevel::kFatal) {
    if (g_log_call_back.flush) {
      g_log_call_back.flush();
    }
    abort();
  }
}

