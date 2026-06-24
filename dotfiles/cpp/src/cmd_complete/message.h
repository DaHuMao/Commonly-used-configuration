#ifndef ZSH_COMPLETE_MESSAGE_H_
#define ZSH_COMPLETE_MESSAGE_H_
#include <cstdint>
struct ClientMessage {
  int8_t command = -1;
  int32_t seq = -1;
  int32_t pid = -1;
  int32_t value_size = 0;
  char value[0];
};

struct ServerMessage {
  int32_t seq = -1;
  int32_t value_size = 0;
  char value[0];
};
#endif  // ZSH_COMPLETE_MESSAGE_H_
