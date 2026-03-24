#!/bin/bash
# 定义环境变量
export MYZSH_DIR=$HOME/.myzsh
export ZSH_CONFIG_DIR=$MYZSH_DIR/zsh_config
export ZSH_REAL_DIR=$(dirname $(readlink -f ~/.zshrc))


# 定义默认平台为MACOS
THIS_PLATFORM=MACOS
INSTALL_CMD="brew install"
#日志打印格式化
#字体颜色 30:黑 31:红 32:绿 33:黄 34:蓝色 35:紫色 36:深绿 37:白色
#背景颜色#40:黑 #41:深红 #42:绿 #43:黄色 #44:蓝色 #45:紫色 #46:深绿 #47:白色

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function log_info(){
    printf "${GREEN}[INFO] %s${NC}\n" "$*"
}

function log_step() {
    printf "${BLUE}==>${NC} $1\n"
}

function log_warn(){
    printf "${YELLOW}[WARNING] %s${NC}\n" "$*"
}

function log_error(){
    printf "${RED}[ERROR] %s${NC}\n" "$*"
}

function log_segment() {
    printf "${BLUE}******************************************${NC}\n"
    printf "${BLUE}****** %s ${NC}\n" "$*"
    printf "${BLUE}******************************************${NC}\n"
}

function log_abort() {
  if [ $# -gt 0 ]; then
    printf "${RED}[ABORT] %s${NC}" "$*"
  fi

  printf "\n${RED}[CALL STACK]${NC}"
  local i
  local stack_size=${#BASH_SOURCE[@]}
  for (( i=stack_size-1 ; i>0 ; i-- )) ; do
    local func="${FUNCNAME[$i]}"
    local line="${BASH_LINENO[$((i-1))]}"
    local src="${BASH_SOURCE[$i]}"
    local stack_index=$((stack_size - i))
    printf "${RED}%d: %s() in %s:%d${NC}\n" \
      "$stack_index" "$func" "$src" "$line"
  done

  exit 1
}

function log_and_return_on_error() {
  if [[ $? -ne 0 ]]; then
    log_error "Error occurred: $1"
    return 1
  fi
}

function check_res_and_abort() {
  if [[ $? -ne 0 ]]; then
    log_abort "Error occurred: $*"
  fi
}

function is_windows() {
  if [[ "$(uname)" == *CYGWIN* || "$(uname)" == *MINGW* || "$(uname)" == *MSYS* ]];then
    return 0
  else
    return 1
  fi
}

function is_macos() {
  if [[ "$(uname)" == *Darwin* ]];then
    return 0
  else
    return 1
  fi
}

function is_ubuntu() {
  if [[ -f /etc/lsb-release ]];then
    return 0
  else
    return 1
  fi
}

function convert_to_unix_path() {
    local win_path="$1"

    # Step 1: Change the drive letter to lowercase and add a leading slash
    # C:\DIR1\DIR2 -> /c/DIR1\DIR2
    unix_path=$(echo "$win_path" | sed -E 's/^([A-Za-z]):/\/\L\1/')

    # Step 2: Replace backslashes with forward slashes
    # /c/DIR1\DIR2 -> /c/DIR1/DIR2
    unix_path=$(echo "$unix_path" | sed 's|\\|/|g')

    echo "$unix_path"
}

if is_windows;then
  THIS_PLATFORM=WINDOWS
  INSTALL_CMD="scoop install"
  MSYS_HOME="/c/msys64"
  if [ -z "$WIN_HOME" ];then
    export WIN_HOME=$MSYS_HOME/home/$USER
    cd $USERPROFILE
    export HOME=$(convert_to_unix_path `pwd`)
    export SCOOP_HOME=${HOME}/scoop/apps
    cd - &> /dev/null
    log_info "WIN_HOME is set to $WIN_HOME"
    log_info "HOME is set to $HOME"
    log_info "SCOOP_HOME is set to $SCOOP_HOME"
  fi
fi

if is_ubuntu;then
  THIS_PLATFORM=LINUX
  INSTALL_CMD="sudo apt install"
fi

if is_macos;then
  THIS_PLATFORM=MACOS
  INSTALL_CMD="brew install"
fi

function install_exe() {
  bin_file=$1
  log_info "Preparing to install ${bin_file} cmd: ${INSTALL_CMD} ${bin_file} ..."
  if is_windows;then
    powershell.exe -NoProfile -Command "scoop install ${bin_file}"
    if [ $? -ne 0 ];then
      log_warn "failed install ${bin_file}, trying cmd: pacman -S ${bin_file}"
      pacman -S ${bin_file} && return 0
    else
      return 0
    fi
  else
    eval "${INSTALL_CMD} ${bin_file}" && return 0
  fi
  log_error "failed install ${bin_file}"
  return 1
}





