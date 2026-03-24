#!/usr/bin/env bash
set -o errexit

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1
tmux_conf_dir="$HOME/.mytmux"
if [[ ! -d $tmux_conf_dir ]]; then
    mkdir -p "$tmux_conf_dir"
fi

ln -sf "$SCRIPT_DIR/tmux.conf" ~/.tmux.conf
ln -sf "$SCRIPT_DIR/fzf_window.sh" $tmux_conf_dir/fzf_window.sh
ln -sf "$SCRIPT_DIR/fzf_select_pane.sh" $tmux_conf_dir/fzf_select_pane.sh
chmod 777 $tmux_conf_dir/fzf_window.sh
chmod 777 $tmux_conf_dir/fzf_select_pane.sh

[[ $(uname) == *Darwin* ]] && ln -sf "$SCRIPT_DIR/tmux_osx.conf" ~/.tmux_osx.conf

# tpm
[[ ! -a ~/.tmux/plugins/tpm ]] && git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# tmuxinator
ln -snf "$SCRIPT_DIR/tmuxinator" ~/.tmuxinator
