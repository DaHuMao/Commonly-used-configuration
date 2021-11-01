#!/usr/bin/env bash

# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1
mkdir -p ~/.myzsh
ln -sf "$SCRIPT_DIR/zshenv"        ~/.myzsh/.zshenv
ln -sf "$SCRIPT_DIR/zshrc"         ~/.myzsh/.zshrc
ln -sf "$SCRIPT_DIR/zsh_aliases"   ~/.myzsh/.zsh_aliases
ln -sf "$SCRIPT_DIR/zsh_keybinds"  ~/.myzsh/.zsh_keybinds
ln -sf "$SCRIPT_DIR/zsh_misc"      ~/.myzsh/.zsh_misc
ln -sf "$SCRIPT_DIR/zsh_custom"    ~/.myzsh/.zsh_custom
ln -sf "$SCRIPT_DIR/zsh_plug"      ~/.myzsh/.zsh_plug
ln -sf "$SCRIPT_DIR/zsh_theme"     ~/.myzsh/.zsh_theme
ln -sf "$SCRIPT_DIR/zsh_fzf_extra" ~/.myzsh/.zsh_fzf_extra
ln -sf "$SCRIPT_DIR/zsh_docker"    ~/.myzsh/.zsh_docker
ln -sf "$SCRIPT_DIR/incr-0.2.zsh"    ~/.myzsh/.incr-0.2.zsh

mkdir -p ~/.myzsh/.zsh_completions
ln -sf "$SCRIPT_DIR/completions/_ag"  ~/.myzsh/.zsh_completions/_ag
ln -sf "$SCRIPT_DIR/completions/_pet" ~/.myzsh/.zsh_completions/_pet
ln -sf "$SCRIPT_DIR/completions/_jq"  ~/.myzsh/.zsh_completions/_jq
ln -sf "$SCRIPT_DIR/completions/_fzf" ~/.myzsh/.zsh_completions/_fzf
ln -sf "$SCRIPT_DIR/completions/_gi"  ~/.myzsh/.zsh_completions/_gi
ln -sf "$SCRIPT_DIR/completions/_hub" ~/.myzsh/.zsh_completions/_hub

ln -sf "$SCRIPT_DIR/zshrc" ~/.zshrc

[[ "$SHELL" =~ "zsh" ]] || chsh -s "$(command -v zsh)"

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

source ~/.zshrc
