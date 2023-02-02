#!/usr/bin/env bash
# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1
ln -sf $SCRIPT_DIR        ~/.myzsh

for bin_file in `ls ~/.myzsh/bin`
do
  chmod 777 ~/.myzsh/bin/$bin_file
done

ln -sf "$SCRIPT_DIR/gitconfig"    ~/.gitconfig

[ ! -e ~/.zshrc ] && touch ~/.zshrc

cat ./zshrc > ~/.zshrc

[[ "$SHELL" =~ "zsh" ]] || chsh -s "$(command -v zsh)"

source ~/.zshrc
