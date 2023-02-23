source ./scrip_tool/script/tool_function.sh

function check_and_install() {
  bin_file=$1
  check_cmd="check_cmd ${bin_file}"
  install_cmd="brew install ${bin_file}"
  log_info "check_and_install ${bin_file} ....."
  eval $check_cmd || (log_info "Preparing to install ${bin_file} ....." && eval $install_cmd && log_info "Successed install ${bin_file}") || log_abort "failed install $bin_file"
  echo ' '
}

function check_and_install_nvm_node() {
  log_info 'check_and_install nvm ......'
  if [ -d ~/.nvm ];then
    log_info 'nvm is aready install'
  else
    log_info 'nvm is not install'
    log_info 'Preparing install nvm .....'
    brew install nvm || log_abort "failed install nvm"
    mkdir ~/.nvm
    log_info 'Successed install nvm'
  fi
  log_info "you can install node. eg: source ./zsh/load_nvm.sh nvm install 13.3.0;nvm use 13.3.0;nvm alias default 13.3.0"
  #source ./zsh/load_nvm.sh
  #log_info 'install node and selecting version of 13.2.0'
  #nvm install 13.2.0 || log_abort "failed to use nvm install node 13.2.0"
  #nvm use 13.2.0
  #nvm alias default 13.2.0
  return 0
}

log_info "check and install brew ....."
 check_cmd brew || /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)" \
   || log_abort "failed install brew"
echo ' ' #空一行

check_and_install 'rg'
check_and_install 'htop'
check_and_install 'bat'
check_and_install 'nvim'
check_and_install 'fzf'
check_and_install 'tree'
check_and_install 'tldr'
check_and_install 'duf'
check_and_install 'exa'
check_and_install 'ncdu'
check_and_install 'HTTPie'
check_and_install 'coreutils'

#nerd-front https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts
#brew tap homebrew/cask-fonts
#brew install --cask font-hack-nerd-font


check_and_install_nvm_node
echo ' ' #空一行
log_info "successed install all-----------------------------"
