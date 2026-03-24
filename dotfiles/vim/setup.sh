#!/bin/bash
set -o errexit
source ../zsh/zsh_config/env.sh
source ../zsh/zsh_config/tool_function.sh
# get the dir of the current script# Function to convert Windows path to Unix path
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1
NVIM_CONFIG_DIR=$HOME/.config/nvim
if is_windows; then
  NVIM_CONFIG_DIR=$HOME/Appdata/Local/nvim
fi

VIM_CONFIG_DIR=~/.vim

mkdir_and_rm $VIM_CONFIG_DIR

for ee in `ls ./`; do
  if [ -d $ee ]; then
    mklink_and_rm ${SCRIPT_DIR}/$ee $VIM_CONFIG_DIR/$ee
  fi
done
mklink_and_rm ${SCRIPT_DIR}/init.vim $VIM_CONFIG_DIR/init.vim
mklink_and_rm $VIM_CONFIG_DIR $NVIM_CONFIG_DIR
mklink_and_rm ${SCRIPT_DIR}/init.vim $HOME/.vimrc

printf "let g:THIS_PLATFORM='%s'\n\n\
function IsMacos()\n\
  return g:THIS_PLATFORM == 'MACOS'\n\
endfunction\n\n\
function! IsMsys2()\n\
  if exists(\"\$MSYSTEM\")\n\
    return \$MSYSTEM ==# 'MSYS' ||\$MSYSTEM ==# 'MINGW32' || \$MSYSTEM ==# 'MINGW64'\n\
  endif\n\
  return filereadable('/usr/bin/msys-2.0.dll')\n\
endfunction\n\n\
function IsWindows()\n\
  return g:THIS_PLATFORM == 'WINDOWS'\n\
endfunction\n\n\
function IsLinux()\n\
  return g:THIS_PLATFORM == 'LINUX'\n\
endfunction\n" "${THIS_PLATFORM}" > ${VIM_CONFIG_DIR}/env.vim

#download vim-plug
plug_dir=$HOME/.vim/autoload/
if is_windows; then
  plug_dir=$NVIM_CONFIG_DIR/autoload/
fi

if [ ! -f $plug_dir/plug.vim ]; then
  log_info "Downloading vim-plug"
  curl -fLo $plug_dir/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

log_info "pip3 install --upgrade neovim"
hash pip3 &>/dev/null && pip3 install --upgrade neovim
log_info "gem install neovim"
hash gem  &>/dev/null && gem install neovim
if is_windows; then
  power_shell nvim -c PlugInstall -c PackInstall -c qall
else
  tty &>/dev/null && nvim +PlugInstall +PackInstall +qall
fi
