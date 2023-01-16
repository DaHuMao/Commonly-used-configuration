#!/usr/bin/env bash

# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1
mkdir -p ~/.myzsh
ln -sf "$SCRIPT_DIR/zshenv"        ~/.myzsh/zshenv
ln -sf "$SCRIPT_DIR/zshrc"         ~/.myzsh/zshrc
ln -sf "$SCRIPT_DIR/zsh_aliases"   ~/.myzsh/zsh_aliases
ln -sf "$SCRIPT_DIR/fzf.zsh"  ~/.myzsh/fzf.zsh
ln -sf "$SCRIPT_DIR/zsh_misc"      ~/.myzsh/zsh_misc
ln -sf "$SCRIPT_DIR/zsh_custom"    ~/.myzsh/zsh_custom
ln -sf "$SCRIPT_DIR/zsh_plug"      ~/.myzsh/zsh_plug
ln -sf "$SCRIPT_DIR/zsh_theme"     ~/.myzsh/zsh_theme
ln -sf "$SCRIPT_DIR/zsh_fzf_extra" ~/.myzsh/zsh_fzf_extra
ln -sf "$SCRIPT_DIR/zsh_docker"    ~/.myzsh/zsh_docker
ln -sf "$SCRIPT_DIR/incr-0.2.zsh"    ~/.myzsh/incr-0.2.zsh
ln -sf "$SCRIPT_DIR/common.zsh"    ~/.myzsh/common.zsh
ln -sf "$SCRIPT_DIR/tool_function.zsh"    ~/.myzsh/tool_function.zsh
ln -sf "$SCRIPT_DIR/git-edit.zsh"    ~/.myzsh/git-edit.zsh
ln -sf "$SCRIPT_DIR/load_nvm.sh"    ~/.myzsh/load_nvm.sh
ln -sf "$SCRIPT_DIR/bin"    ~/.myzsh/bin
ln -sf "$SCRIPT_DIR/remind_cmd"    ~/.myzsh/remind_cmd

for bin_file in `ls ~/.myzsh/bin`
do
  chmod 777 ~/.myzsh/bin/$bin_file
done

mkdir -p ~/.myzsh/zsh_completions
ln -sf "$SCRIPT_DIR/completions/_ag"  ~/.myzsh/zsh_completions/_ag
ln -sf "$SCRIPT_DIR/completions/_pet" ~/.myzsh/zsh_completions/_pet
ln -sf "$SCRIPT_DIR/completions/_jq"  ~/.myzsh/zsh_completions/_jq
ln -sf "$SCRIPT_DIR/completions/_fzf" ~/.myzsh/zsh_completions/_fzf
ln -sf "$SCRIPT_DIR/completions/_gi"  ~/.myzsh/zsh_completions/_gi
ln -sf "$SCRIPT_DIR/completions/_hub" ~/.myzsh/zsh_completions/_hub

ln -sf "$SCRIPT_DIR/gitconfig"    ~/.gitconfig

[ ! -e ~/.zshrc ] && touch ~/.zshrc

cat ./zshrc > ~/.zshrc

[[ "$SHELL" =~ "zsh" ]] || chsh -s "$(command -v zsh)"

source ~/.zshrc
