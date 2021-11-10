#!/bin/bash
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

session_windows=$(tmux list-windows -a -F '#S:#I:#W')
current_window=$(tmux display-message -p '#S:#I:#W')
windows=$(echo "$session_windows"|grep -v "^$current_window\$")


echo "$windows"\
 | fzf --reverse --header="select session window" --preview="$current_dir/.preview {}"\
 | awk -F ":"  '{printf("switch-client -t %s ; select-window -t %s", $1, $2)}'\
 | xargs tmux
