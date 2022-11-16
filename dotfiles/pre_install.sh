source ./scrip_tool/script/tool_function.sh

function check_and_install() {
  bin_file=$1
  check_cmd="check_cmd ${bin_file}"
  install_cmd="brew install ${bin_file}"
  log_info "check_and_install ${bin_file} ....."
  eval $check_cmd || (log_info "Preparing to install ${bin_file} ....." && eval $install_cmd && log_info "Successed install ${bin_file}") || log_abort "failed install $bin_file"
}

log_info "check install brew"
 check_cmd brew || /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)" \
   || log_abort "failed install brew"

check_and_install 'rg'
check_and_install 'htop'
check_and_install 'bat'
check_and_install 'nvim'
check_and_install 'fzf'
check_and_install 'nvm'

nvm install 13.2.0 || log_abort "failed to use nvm install node 13.2.0"
nvm use 13.2.0
nvm alias default 13.2.0
log_info "successed install all-----------------------------"
