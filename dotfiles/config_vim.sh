#!/bin/bash
set -o errexit
source zsh/zsh_config/env.sh
source zsh/zsh_config/tool_function.sh
printf "let g:THIS_PLATFORM='%s'\n\n\
function IsMacos()\n\
  return g:THIS_PLATFORM == 'MACOS'\n\
endfunction\n\n\
function IsWindows()\n\
  return g:THIS_PLATFORM == 'WINDOWS'\n\
endfunction\n\n\
function IsLinux()\n\
  return g:THIS_PLATFORM == 'LINUX'\n\
endfunction\n" "${THIS_PLATFORM}" > vim/configs/env.vim
# get the dir of the current script# Function to convert Windows path to Unix path
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1
NVIM_CONFIG_DIR=$HOME/.config/nvim
if is_windows; then
  NVIM_CONFIG_DIR=$WIN_HOME/Appdata/Local/nvim
fi

VIM_CONFIG_DIR=~/.vim

mklink ${SCRIPT_DIR}/vim ${NVIM_CONFIG_DIR}
mklink ${SCRIPT_DIR}/vim $VIM_CONFIG_DIR
mklink ${SCRIPT_DIR}/vim/init.vim $HOME/.vimrc

log_info "pip3 install --upgrade neovim"
hash pip3 &>/dev/null && pip3 install --upgrade neovim
log_info "gem install neovim"
hash gem  &>/dev/null && gem install neovim
tty &>/dev/null && nvim +PlugInstall +PackInstall +qall
