#!/bin/bash

# 获取当前会话的名称
current_session=$(tmux display-message -p '#S')

# 获取当前 pane 的编号
current_pane=$(tmux display-message -p '#P')

# 获取当前会话的所有 panes 列表，排除当前 pane
panes=$(tmux list-panes -F "#{session_name}:#{pane_current_path} #P" | grep "^$current_session" | grep -v "$current_pane$")

max_lines=100

# 使用 fzf 选择一个 pane，并预览其内容
selected_pane=$(echo "$panes" | fzf  --ansi \
  --color='bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796' \
  --color='fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6' \
  --color='marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796' \
  --bind 'ctrl-/:toggle-preview' \
  --bind ctrl-b:preview-half-page-up,ctrl-n:preview-half-page-down \
  --preview "tmux capture-pane -pe -t {2} | tail -n ${max_lines}"\
  --preview-window up,70%,border-bottom,+10 \
)

# 如果选择了一个 pane，则跳转到该 pane
if [ -n "$selected_pane" ]; then
    pane_id=$(echo "$selected_pane" | awk '{print $2}')
    tmux select-pane -t "$pane_id" && tmux resize-pane -Z
fi

