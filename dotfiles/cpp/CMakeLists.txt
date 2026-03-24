cmake_minimum_required(VERSION 3.10)
project(MyProject)
# 设置 C++ 标准为 C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (TEST)
  add_definitions(-DIS_IN_TEST)
endif()
if (WIN32)
    message(STATUS "Building on Windows")
    add_definitions(-DWIN_PLATFORM)
elseif (UNIX)
    message(STATUS "Building on a Unix-like system")
    add_definitions(-DUNIX_LIKE_PLATFORM)
else()
    message(STATUS "Building on an unknown platform")
endif()

if (DEFINED ENV{ZSH_CACHE_DIR})
    message(STATUS "ZSH_CACHE_DIR is set to $ENV{ZSH_CACHE_DIR}")
    add_definitions(-DZSH_CACHE_DIR="$ENV{ZSH_CACHE_DIR}")
endif()

if (DEFINED ENV{ZSH_SOCKET_DIR})
    message(STATUS "ZSH_SOCKET_DIR is set to $ENV{ZSH_SOCKET_DIR}")
    add_definitions(-DZSH_SOCKET_DIR="$ENV{ZSH_SOCKET_DIR}")
endif()

if (DEFINED ENV{CUSTOM_ZSH_HISTORY_FILE})
    message(STATUS "CUSTOM_ZSH_HISTORY_FILE is set to $ENV{CUSTOM_ZSH_HISTORY_FILE}")
    add_definitions(-DCUSTOM_ZSH_HISTORY_FILE="$ENV{CUSTOM_ZSH_HISTORY_FILE}")
endif()

if (DEFINED ENV{ZSH_FIFO_DIR})
    message(STATUS "ZSH_FIFO_DIR is set to $ENV{ZSH_FIFO_DIR}")
    add_definitions(-DZSH_FIFO_DIR="$ENV{ZSH_FIFO_DIR}")
endif()

# Common source files
#set(COMMON_SOURCES
#)

# Platform-specific source files
#if (WIN32)
#    set(PLATFORM_SOURCES
#    )
#elseif (APPLE)
#    set(PLATFORM_SOURCES
#    )
#endif()

#header files
include_directories(
  src
)

set(base
  src/base/log.cc
  src/base/util.cc
  src/base/check.cc
  src/base/interval_dict_tree.cc
  src/base/ring_vector.cc
  src/base/pipe.cc
  src/base/local_udp_socket.cc
)

set(client_src
  src/test/noblock_read.cc
)

set(pipe_server_src
  src/test/pipe_server.cc
)

set(zsh_complete_client_test
  src/test/zsh_complete_client_test.cc
  ./src/zsh_complete/define.cc
)

set(test_socket_server_src
  src/test/test_socket_server.cc
  src/zsh_complete/define.cc
)

set(test_socket_client_src
  src/test/test_socket_client.cc
  src/zsh_complete/define.cc
)

# Define executables and link relevant sources
#add_executable(main1 src/main1.cc src/util1.cc ${COMMON_SOURCES} ${PLATFORM_SOURCES})

if (UNIT_TEST)
  add_executable(noblock_read ${client_src} ${base})
  add_executable(pipe_server ${pipe_server_src} ${base})
  add_executable(zsh_complete_client_test ${zsh_complete_client_test} ${base})
  add_executable(test_array_list src/test/test_array_list.cc ${base})
  add_executable(test_interval_dict_tree
    src/test/test_interval_dict_tree.cc
    src/test/test_util.cc
    ${base}
  )
  add_executable(test_history_data
    src/test/test_history_data.cc
    src/zsh_complete/zsh_complete_server/history_data.cc
    src/test/test_util.cc
    ${base}
  )
  add_executable(test_socket_server ${test_socket_server_src} ${base})
  add_executable(test_socket_client ${test_socket_client_src} ${base})
endif()

add_subdirectory(src/zsh_complete)



