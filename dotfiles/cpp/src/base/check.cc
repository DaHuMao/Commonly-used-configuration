#include "check.h"
#include "log.h"

FatalMessage::FatalMessage(const char* file, int line, const char* func) {
  ss_ << file << ":" << line << " " << func << " ";
}

FatalMessage::~FatalMessage() {
  LOG_F("FatalMessage") << ss_.str() << " aborting....";
}
