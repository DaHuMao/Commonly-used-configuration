#!/bin/bash
# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1
TARGET_VIM_DIR=~/.vim/
TARGET_NVIM_DIR=~/.config/nvim/

mkdir -p ~/.vim/spell ~/.config



echo "link configs $SCRIPT_DIR to .vim dir"
ln -s "$SCRIPT_DIR/configs" $TARGET_VIM_DIR/configs
ln -s "$SCRIPT_DIR/autoload" $TARGET_VIM_DIR/autoload
ln -s "$SCRIPT_DIR/snippets" $TARGET_VIM_DIR/snippets

ln -sf "$SCRIPT_DIR/vimrc.vim" ~/.vimrc
ln -sf "$SCRIPT_DIR/coc-settings.json" $TARGET_NVIM_DIR/coc-settings.json
ln -sf "$SCRIPT_DIR/settings.json" $TARGET_NVIM_DIR/settings.json

ln -sf "$SCRIPT_DIR/lua" $TARGET_NVIM_DIR/lua
ln -sf "$SCRIPT_DIR/ftplugin" $TARGET_NVIM_DIR/ftplugin
# Install plugins managed by vim-plug
# `tty &>/dev/null` is to make sure the script is run from a tty(ie, not ssh)
if hash nvim &>/dev/null ; then
    ln -snf ~/.vim   ~/.config/nvim
    ln -sf  ~/.vimrc ~/.config/nvim/init.vim
fi

# nvim
#if hash nvim &>/dev/null ; then
    hash pip2 &>/dev/null && pip2 install --upgrade neovim
    hash pip3 &>/dev/null && pip3 install --upgrade neovim
    hash gem  &>/dev/null && gem install neovim
    tty &>/dev/null && nvim +PlugInstall +qall
#  else
#    tty &>/dev/null && vim +PlugInstall +qall
#fi
