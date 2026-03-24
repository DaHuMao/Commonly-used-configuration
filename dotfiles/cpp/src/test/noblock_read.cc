#include <stdio.h>
#include <fcntl.h>
#include <sys/select.h>
#include <unistd.h>
#include <cstring>
#include <sstream>
#include <string>
#include "./pipe_test_define.h"
#include "base/pipe.h"

#define BUFFER_SIZE 1024

int main(int argc, char* argv[]) {
  PipeReader reader(S2C_FIFO_PATH, false);
  PipeWriter writer(C2S_FIFO_PATH);
    std::string str = "";
    for ( int i = 1; i < argc; i++ ) {
        str += argv[i];
        str += " ";
    }
    fd_set readfds;
    struct timeval tv;
    int write_size = writer.Write(str.c_str(), str.size());
    if (write_size == -1) {
        printf("Write to FIFO failed\n");
        return 1;
    }
    printf("Write %d bytes: %s\n", write_size, str.c_str());
    char buffer[BUFFER_SIZE];
    int read_size = reader.Read(buffer, BUFFER_SIZE - 1);
    if (read_size == -1) {
      printf("No data within 200 milliseconds\n");
    } else if (read_size > 0) {
      buffer[read_size] = '\0';
      printf("Read %d bytes: %s\n", read_size, buffer);
    }
    return 0;
}

