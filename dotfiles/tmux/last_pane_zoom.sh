#!/usr/bin/env bash

target=$(tmux display-message -p "#{@last_focused_pane}")

if [[ -z "$target" ]]; then
    tmux display-message "No last focused pane recorded"
    exit 0
fi

if ! tmux select-pane -t "$target"; then
    exit 0
fi

if [[ "$(tmux display-message -p -t "$target" "#{window_zoomed_flag}")" != "1" ]]; then
    tmux resize-pane -Z -t "$target"
fi
