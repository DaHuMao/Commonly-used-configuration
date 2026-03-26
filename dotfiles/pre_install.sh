set -o errexit
source zsh/zsh_config/env.sh
source zsh/zsh_config/tool_function.sh

build_vim=0
build_zsh=0
build_all=0

case $1 in
  -v|--vim)
    build_vim=1
    ;;
  -z|--zsh)
    build_zsh=1
    ;;
  -a|--all)
    build_all=1
    ;;
  *)
    log_abort "Usage: $0 [-v|--vim] [-z|--zsh] [-a|--all]"
    ;;
esac

if [ $build_all -eq 1 ];then
  build_vim=1
  build_zsh=1
fi

#===================================== brew install ===================================
#check if is mac platform and exist brew
if is_macos;then
  if ! check_cmd brew;then
    log_info "Preparing to install brew ....."
    /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)" || log_abort "failed install brew"
    echo ' ' #空一行
    #echo ' 选择 brew 源'
    #cd ./scrip_tool/script/
    #./brew_origion.sh || log_abort "failed to change brew origion"
    #cd -
  else
    log_info "brew is already installed"
  fi
fi
#====================================  brew install ===================================

#scoop install
if is_windows;then
  if ! check_cmd scoop;then
    log_info "Preparing to install scoop ....."
    PowerShell.exe -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" || log_abort "failed to set execution policy"
    PowerShell.exe -Command "iwr -useb get.scoop.sh | iex" || log_abort "failed install scoop"
    export PATH=$HOME/scoop/shims:$PATH
  else
    log_info "scoop is already installed"
  fi
fi


function check_and_install() {
  bin_file=$1
  log_info "check_and_install ${bin_file} ....."
  check_cmd ${bin_file} || (install_exe $bin_file && log_info "Successed install ${bin_file}") || log_abort "failed install $bin_file"
  echo ' '
}

function check_and_install_nvm_node() {
  log_info 'check_and_install nvm ......'
  if [ -d ~/.nvm ];then
    log_info 'nvm is already install'
  else
    log_info 'nvm is not install'
    log_info 'Preparing install nvm .....'
    install_exe nvm || log_abort "failed install nvm"
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

check_and_install 'git'
check_and_install 'ripgrep'
check_and_install 'fd'
check_and_install 'bat'
check_and_install 'fzf'
check_and_install 'tree'
check_and_install_nvm_node

if [ $build_vim -eq 1 ];then
  check_and_install 'nvim'
  if is_windows; then
    check_cmd python3 || log_abort "python3 is not installed"
    check_cmd pip3 || log_abort "pip3 is not installed"

    log_info 'install clang gcc ......'
    check_cmd clang || pacman -S mingw-w64-x86_64-clang
    check_cmd gcc ||pacman -S mingw-w64-x86_64-gcc
  else
    check_and_install 'pyenv'
    pyenv install python3
    check_and_install 'clang'
    check_and_install 'gcc'
    #安装rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi
  check_and_install 'ruby'
  check_and_install 'wget'
  check_and_install 'curl'
  check_and_install 'luarocks'
  check_and_install 'cmake'
fi

if [ $build_zsh -eq 1 ]; then
  check_and_install 'zsh'
  check_and_install 'diff-so-fancy'
fi

if ! is_windows;then
  if [ $build_all -eq 1 ];then
    check_and_install 'tmux'
    check_and_install 'ncdu'
    check_and_install 'htop'
    check_and_install 'HTTPie'
    check_and_install 'duf'
  fi
fi

if is_macos;then
  check_and_install 'coreutils'
  check_and_install 'gnu-sed'
fi

#nerd-front https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts
if is_macos;then
  brew tap homebrew/cask-fonts
  brew install --cask font-fira-code-nerd-font
elif is_windows;then
  scoop bucket add nerd-fonts
  scoop install Hack-NF
fi

echo ' ' #空一行
log_info "successed install all-----------------------------"
