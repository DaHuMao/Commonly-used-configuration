#!/bin/bash
# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

mkdir -p ~/.vim/spell ~/.config

echo "link configs to .vim dir"
#ln -s "$SCRIPT_DIR/configs" ~/.vim/configs
#ln -s "$SCRIPT_DIR/autoload" ~/.vim/autoload

ln -sf "$SCRIPT_DIR/vimrc.vim" ~/.vimrc
ln -sf "$SCRIPT_DIR/projects.vim" ~/.vim/projects.vim
ln -sf "$SCRIPT_DIR/coc-settings.json" ~/.vim/coc-settings.json
ln -sf "$SCRIPT_DIR/settings.json" ~/.vim/settings.json
exit

# Install plugins managed by vim-plug
# `tty &>/dev/null` is to make sure the script is run from a tty(ie, not ssh)
if hash nvim &>/dev/null ; then
    ln -snf ~/.vim   ~/.config/nvim
    ln -sf  ~/.vimrc ~/.config/nvim/init.vim
fi

# nvim
if hash nvim &>/dev/null ; then
    ln -snf ~/.vim   ~/.config/nvim
    ln -sf  ~/.vimrc ~/.config/nvim/init.vim
    hash pip2 &>/dev/null && pip2 install --upgrade neovim
    hash pip3 &>/dev/null && pip3 install --upgrade neovim
    #hash gem  &>/dev/null && gem install neovim
    tty &>/dev/null && nvim +PlugInstall +qall
  else
    tty &>/dev/null && vim +PlugInstall +qall
fi
