#!/bin/bash

BUIILD_TYPE=Release
BUILD_WITH_IDE=0
CMAKE_PARAM=""
echo "Number of arguments: $#"
while [[ $# > 0 ]]; do
  case $1 in
    "--debug")
      BUIILD_TYPE=Debug
      ZSH_SOCKET_DIR="./tmp/zsh_socket"
      ZSH_CACHE_DIR="./tmp/zsh_cache"
      shift
      ;;
    "--ide")
      BUILD_WITH_IDE=1
      shift
      ;;
    "--test")
      CMAKE_PARAM="-DTEST=1"
      shift
      ;;
    "--zsh_module")
      CMAKE_PARAM="$CMAKE_PARAM -DZSH_MODULE=1"
      shift
      ;;
    "--zsh_server")
      CMAKE_PARAM="$CMAKE_PARAM -DZSH_SERVER=1"
      shift
      ;;
    "--unit_test")
      CMAKE_PARAM="$CMAKE_PARAM -DUNIT_TEST=1"
      shift
      ;;
    "--all")
      CMAKE_PARAM="$CMAKE_PARAM -DZSH_MODULE=1 -DUNIT_TEST=1 -DZSH_SERVER=1"
      shift
      ;;
    *)
      echo "invalid param $2"
      echo "Usage: $0 [--debug] [--ide] [--test] [--zsh_module] [--zsh_server] [--unit_test] [--all]"
      exit 1
  esac
done

#检查是否有CUSTOM_ZSH_HISTORY_FILE环境变量
if [ ! -z "$CUSTOM_ZSH_HISTORY_FILE" ]; then
  CMAKE_PARAM="$CMAKE_PARAM -DCUSTOM_ZSH_HISTORY_FILE=$CUSTOM_ZSH_HISTORY_FILE"
fi

if [ ! -z "$ZSH_CACHE_DIR" ]; then
  CMAKE_PARAM="$CMAKE_PARAM -DZSH_CACHE_DIR=$ZSH_CACHE_DIR"
fi

if [ ! -z "$ZSH_SOCKET_DIR" ]; then
  CMAKE_PARAM="$CMAKE_PARAM -DZSH_SOCKET_DIR=$ZSH_SOCKET_DIR"
fi

if [ ! -z "$ZSH_FIFO_DIR" ]; then
  CMAKE_PARAM="$CMAKE_PARAM -DZSH_FIFO_DIR=$ZSH_FIFO_DIR"
fi

echo "Build type: $BUIILD_TYPE"
echo "Build with IDE: $BUILD_WITH_IDE"
echo "CMAKE_PARAM: $CMAKE_PARAM"
BUILD_DIR=build
if [ $BUILD_WITH_IDE -eq 1 ]; then
  BUILD_DIR=build_ide
fi
if [  -d $BUILD_DIR ]; then
  rm -rf $BUILD_DIR
fi

mkdir -p $BUILD_DIR
cd $BUILD_DIR

CMAKE_DEFINE="-DCMAKE_BUILD_TYPE=$BUIILD_TYPE -DUNIX=1 $CMAKE_PARAM"

if [ $BUILD_WITH_IDE -eq 1 ]; then
  cmake $CMAKE_DEFINE -G Xcode ..
else
  cmake $CMAKE_DEFINE -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..
  cmake --build . -j8
fi

