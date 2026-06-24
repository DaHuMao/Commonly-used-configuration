#cmake hello word
cmake_minimum_required(VERSION 3.10)
project(hello)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/../zsh_module_common
  ${CMAKE_CURRENT_SOURCE_DIR}
)

add_definitions(-DMODULE)

if (ZSH_MODULE)
  add_library(custom_zsh_complete MODULE
    ./define.cc
    ./zsh_module/zsh_complete.cc
    ../zsh_util/function_load.cc
    ../base/local_udp_socket.cc
    ../base/check.cc
    ../base/log.cc
  )

  # 设置Windows的链接选项以忽略未解析的符号
  if(WIN32)
      target_link_options(custom_zsh_complete PRIVATE "/FORCE:UNRESOLVED")
  elseif(APPLE)
      # macOS的链接选项以忽略未解析的符号
      target_link_options(custom_zsh_complete PRIVATE "-Wl,-x" "-bundle" "-undefined" "suppress" "-flat_namespace")
  elseif(UNIX)
      # Linux上的链接选项以忽略未解析的符号
      target_link_options(custom_zsh_complete PRIVATE "-Wl,--unresolved-symbols=ignore-in-object-files")
  endif()
endif()

if (ZSH_SERVER)
  add_executable(zsh_complete_server
    ./define.cc
    ./zsh_complete_server/zsh_complete_server.cc
    ./zsh_complete_server/history_data.cc
    ../base/local_udp_socket.cc
    ../base/check.cc
    ../base/log.cc
    ../base/util.cc
  )
endif()

