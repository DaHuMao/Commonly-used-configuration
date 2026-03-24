source $ZSH_CONFIG_DIR/env.sh
source $ZSH_CONFIG_DIR/tool_function.sh

ZSH_CACHE_DIR="$ZSH_COMPETE_DIR/.cache"
ZSH_SOCKET_DIR="$ZSH_COMPETE_DIR/.socket"
CUSTOM_ZSH_HISTORY_FILE="${ZSH_CACHE_DIR}/history_data.txt"
if [[ ! -d "${ZSH_SOCKET_DIR}" ]]; then
  mkdir -p "${ZSH_SOCKET_DIR}"
fi
if [[ ! -d "${ZSH_CACHE_DIR}" ]]; then
  mkdir -p "${ZSH_CACHE_DIR}"
fi

# Version checking function
function check_and_cleanup_version() {
  local source_version_file="$ZSH_REAL_DIR/../cpp/src/zsh_complete/version.h"
  local deploy_version_file="$ZSH_COMPETE_DIR/version.h"
  local server_binary="$ZSH_COMPETE_DIR/zsh_complete_server"
  local module_library="$ZSH_COMPETE_DIR/libcustom_zsh_complete.so"

  if [[ ! -f "$source_version_file" ]]; then
    log_warn "Source version file not found: $source_version_file"
    return 1
  fi

  # Extract versions from source version.h
  local source_server_version=$(grep 'COMPLETE_SERVER_VERSION' "$source_version_file" | sed 's/.*"\(.*\)".*/\1/')
  local source_client_version=$(grep 'COMPLETE_CLIENT_VERSION' "$source_version_file" | sed 's/.*"\(.*\)".*/\1/')

  if [[ -z "$source_server_version" || -z "$source_client_version" ]]; then
    log_warn "Failed to extract versions from source version.h"
    return 1
  fi

  log_info "Source versions: server=$source_server_version, client=$source_client_version"

  local need_cleanup_server=0
  local need_cleanup_client=0

  # Check if deployed version file exists
  if [[ ! -f "$deploy_version_file" ]]; then
    log_warn "Deployed version file not found, need to rebuild all"
    need_cleanup_server=1
    need_cleanup_client=1
  else
    # Extract versions from deployed version.h
    local deploy_server_version=$(grep 'COMPLETE_SERVER_VERSION' "$deploy_version_file" | sed 's/.*"\(.*\)".*/\1/')
    local deploy_client_version=$(grep 'COMPLETE_CLIENT_VERSION' "$deploy_version_file" | sed 's/.*"\(.*\)".*/\1/')

    log_info "Deployed versions: server=$deploy_server_version, client=$deploy_client_version"

    # Check server version mismatch
    if [[ "$deploy_server_version" != "$source_server_version" ]]; then
      log_warn "Server version mismatch: source=$source_server_version, deployed=$deploy_server_version"
      need_cleanup_server=1
    fi

    # Check client version mismatch
    if [[ "$deploy_client_version" != "$source_client_version" ]]; then
      log_warn "Client version mismatch: source=$source_client_version, deployed=$deploy_client_version"
      need_cleanup_client=1
    fi
  fi

  # Cleanup server if version mismatch detected
  if [[ $need_cleanup_server -eq 1 ]]; then
    log_info "Server version mismatch detected, cleaning up server files..."

    # Kill running server process
    if pgrep -x "zsh_complete_server" > /dev/null; then
      log_info "Killing running zsh_complete_server process..."
      pkill -9 -x "zsh_complete_server"
    fi

    # Remove old server binary
    if [[ -f "$server_binary" ]]; then
      rm -f "$server_binary"
      log_info "Removed old server binary"
    fi

    log_info "Server cleanup completed, will rebuild server"
  fi

  # Cleanup client if version mismatch detected
  if [[ $need_cleanup_client -eq 1 ]]; then
    log_info "Client version mismatch detected, cleaning up client files..."

    # Remove old module library
    if [[ -f "$module_library" ]]; then
      rm -f "$module_library"
      log_info "Removed old module library"
    fi

    # Remove bundle file on macOS
    if is_macos && [[ -f "$ZSH_COMPETE_DIR/libcustom_zsh_complete.bundle" ]]; then
      rm -f "$ZSH_COMPETE_DIR/libcustom_zsh_complete.bundle"
      log_info "Removed old bundle file"
    fi

    log_info "Client cleanup completed, will rebuild client"
  fi
}

# Run version check before proceeding
check_and_cleanup_version
log_and_return_on_error "Version check failed" || return 1

if [[ ! -f "${CUSTOM_ZSH_HISTORY_FILE}" ]]; then
  cd $ZSH_REAL_DIR/../cpp
  clang++ -std=c++17 -o transfer_history src/test/transform_history_data.cc
  log_and_return_on_error "failed to compile transfer_history"
  ./transfer_history $HISTFILE ${CUSTOM_ZSH_HISTORY_FILE}
  rm -f transfer_history
  log_and_return_on_error "failed to run transfer_history"
  cd -
fi

function build_zsh_complete() {
  cd $ZSH_REAL_DIR/../cpp
  if is_macos; then
    log_info "Building zsh_complete for MacOS"
    ZSH_SOCKET_DIR=$ZSH_SOCKET_DIR ZSH_CACHE_DIR=$ZSH_CACHE_DIR CUSTOM_ZSH_HISTORY_FILE=$CUSTOM_ZSH_HISTORY_FILE bash build_mac.sh --zsh_module
    log_and_return_on_error "build_mac.sh failed" || return 1
    cp build/src/zsh_complete/libcustom_zsh_complete.so $ZSH_COMPETE_DIR
    mklink $ZSH_COMPETE_DIR/libcustom_zsh_complete.so $ZSH_COMPETE_DIR/libcustom_zsh_complete.bundle
  elif is_windows; then
    log_info "Building zsh_complete for Windows"
    bash build_win.sh --zsh_module
    log_and_return_on_error "build_win.sh failed" || return 1
  else
    log_and_return_on_error "Unsupported platform" || return 1
  fi
  cd -
}

function build_zsh_server() {
  cd $ZSH_REAL_DIR/../cpp
  if is_macos; then
    log_info "Building zsh_server for MacOS"
    ZSH_SOCKET_DIR=$ZSH_SOCKET_DIR ZSH_CACHE_DIR=$ZSH_CACHE_DIR CUSTOM_ZSH_HISTORY_FILE=$CUSTOM_ZSH_HISTORY_FILE bash build_mac.sh --zsh_server
    log_and_return_on_error "build_mac.sh failed" || return 1
    cp build/src/zsh_complete/zsh_complete_server $ZSH_COMPETE_DIR
  elif is_windows; then
    log_info "Building zsh_server for Windows"
    bash build_win.sh --zsh_server
    log_and_return_on_error "build_win.sh failed" || return 1
    cp build/zsh_server $ZSH_COMPETE_DIR
  else
    log_and_return_on_error "Unsupported platform" || return 1
  fi
  cd -
}

if ! pgrep -x "zsh_complete_server" > /dev/null
then
  if [[ ! -f $ZSH_COMPETE_DIR/zsh_complete_server ]];then
    build_zsh_server
    log_info "ZSH_CACHE_DIR: $ZSH_CACHE_DIR"
  fi
  log_info "test zsh_complete_server..."
  $ZSH_COMPETE_DIR/zsh_complete_server --test
  log_and_return_on_error "failed to run zsh_server" || return 1
  log_info "zsh_server 进程不存在，启动它..."
  nohup $ZSH_COMPETE_DIR/zsh_complete_server > /dev/null 2>&1 &
  log_info "zsh_server 已在后台启动 ..."
else
  log_info "zsh_server 进程已经在运行 ..."
fi

if [[ ! -f $ZSH_COMPETE_DIR/libcustom_zsh_complete.so ]];then
  build_zsh_complete
  log_and_return_on_error "build_zsh_complete failed" || return 1
fi

# Copy version.h to deployed directory
log_info "Copying version.h to $ZSH_COMPETE_DIR..."
cp "$ZSH_REAL_DIR/../cpp/src/zsh_complete/version.h" "$ZSH_COMPETE_DIR/version.h"
log_and_return_on_error "Failed to copy version.h"

