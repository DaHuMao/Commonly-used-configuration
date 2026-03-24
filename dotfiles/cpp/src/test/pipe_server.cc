
#include "./pipe_test_define.h"
#include "base/pipe.h"

int main (int argc, char *argv[]) {
  PipeReader reader(C2S_FIFO_PATH);
  PipeWriter writer(S2C_FIFO_PATH);
  char buffer[1024];
  while (true) {
    int len = reader.Read(buffer, sizeof(buffer) - 1);
    if (len > 0) {
      buffer[len] = '\0';
      std::string response = "Echo: ";
      response += buffer;
      writer.Write(response.c_str(), response.size());
      printf("Server wrote %d bytes: %s\n", (int)response.size(), response.c_str());
    }
  }
}
