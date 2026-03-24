#!/bin/bash
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
session_windows=$(tmux list-windows -a -F '#S:#I:#W')
current_window=$(tmux display-message -p '#S:#I:#W')
windows=$(echo "$session_windows"|grep -v "^$current_window\$")

echo "$windows" \
| fzf --ansi --delimiter : \
  --color='bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796' \
  --color='fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6' \
  --color='marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796' \
  --preview-window up,70%,border-bottom \
  --bind ctrl-b:preview-half-page-up,ctrl-n:preview-half-page-down \
  --preview 'tmux capture-pane -pe -t {1} ' \
 | awk -F ":"  '{printf("switch-client -t %s ; select-window -t %s", $1, $2)}'\
 | xargs tmux

