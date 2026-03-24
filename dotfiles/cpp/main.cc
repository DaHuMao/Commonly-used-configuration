#include <stdio.h>
#include <cstdio>
#include <string>
#include <iostream>


std::string encode(const char* data, size_t length) {
    std::string output;
    output.reserve(length * 2); // 预分配空间

    for (size_t i = 0; i < length; ++i) {
        unsigned char byte = static_cast<unsigned char>(data[i]);

        // 规则1: 转义符号自身
        if (byte == '!') {
            output += "!!";
        } else if (byte == '^') {
            output += "^^";

        // 规则2: 处理 0x7F-0xFF
        } else if (byte >= 0x7F) {
            char marker;
            unsigned char mapped;

            if (byte <= 0xCE) {
                marker = '!';
                mapped = ((byte >> 4) - 5) << 4 | (byte & 0x0F);
            } else {
                marker = '^';
                mapped = ((byte >> 4) - 10) << 4 | (byte & 0x0F);
            }

            output += marker;
            output += static_cast<char>(mapped);
        } else {
            // 安全字符直接输出
            output += data[i];
        }
    }

    return output;
}

static char decoded_buffer[1024 * 2];
static char* decode_binary(const char* input) {
  char* ptr = decoded_buffer;
    while (*input) {
        if (*input == '!') {
            if (input[1] == '!') { // 转义的!
                *ptr++ = '!';
                input += 2;
            } else {
                // 解析!转义字符 (0x7F-0xCE)
                unsigned char byte = (unsigned char)input[1];
                byte = ((byte >> 4) + 5) << 4 | (byte & 0x0F);
                *ptr++ = (char)byte;
                input += 2;
            }
        } else if (*input == '^') {
            if (input[1] == '^') { // 转义的^
                *ptr++ = '^';
                input += 2;
            } else {
                // 解析^转义字符 (0xCF-0xFF)
                unsigned char byte = (unsigned char)input[1];
                byte = ((byte >> 4) + 10) << 4 | (byte & 0x0F);
                *ptr++ = (char)byte;
                input += 2;
            }
        } else {
            // 直接复制安全字符
            *ptr++ = *input++;
        }
    }
    *ptr = '\0';
    std::cout << "Decoded string: " << decoded_buffer << std::endl;
    return decoded_buffer;
}

std::string encode(const std::string& input) {
    return encode(input.data(), input.size());
}

std::string decode(const std::string& input) {
  std::cout << "Decoding input: " << input << std::endl;
  return decode_binary(input.data());
}

int main (int argc, char *argv[]) {
  for (int i = 1; i < argc; i++) {
    printf("i: %d ---- \n", i);
    for (size_t j = 0; j < strlen(argv[i]); j++) {
      printf(" %02X", static_cast<unsigned char>(argv[i][j]));
    }
    printf("\n");
    auto encode_str = encode(argv[i]);
    for (size_t j = 0; j < encode_str.size(); j++) {
      printf(" %02X", static_cast<unsigned char>(encode_str[j]));
    }
    printf("\n");
    auto decode_str = decode(encode_str);
    printf("decode_str: %s\n", decode_str.c_str());
  }
  return 0;
}
