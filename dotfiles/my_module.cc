#include <iostream>
#include <zsh/zsh.h>

// 确保使用 C 语言方式的符号名
extern "C" {

// 处理函数，实现具体功能
static int my_hello_world(char *name) {
    std::cout << "Hello, ";
    if (name && *name) {
        std::cout << name;
    } else {
        std::cout << "World";
    }
    std::cout << "!" << std::endl;
    return 0;
}

// 定义 Zsh 内置命令
static struct builtin bintab[] = {
    BUILTIN("my_hello_world", 0, my_hello_world, 0, 1, 0, "", "")
};

// 必要的模块初始化函数：setup_, boot_, cleanup_, finish_
int setup_(Module m) {
    return 0;
}

int boot_(Module m) {
    return addbuiltins(m->nam, bintab, sizeof(bintab) / sizeof(*bintab));
}

int cleanup_(Module m) {
    return 0;
}

int finish_(Module m) {
    return 0;
}

} // extern "C"

