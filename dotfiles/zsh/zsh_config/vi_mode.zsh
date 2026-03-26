bindkey -v
bindkey '^[' vi-cmd-mode

# 光标形状管理 - 确保从 neovim 返回后光标是竖线
function zle-line-init zle-keymap-select {
  # 设置竖线光标 (插入模式)
  printf '\033[5 q'
}
zle -N zle-line-init
zle -N zle-keymap-select

function vi-end-of-line {
  zle end-of-line
}

function vi-beginning-of-line {
  zle beginning-of-line
}

function edit-command-line {
  echo $BUFFER > ~/.zsh_temp
  nvim ~/.zsh_temp
  BUFFER=$(<~/.zsh_temp)
  zle redisplay
}

function clear-rbuf {
  BUFFER=$LBUFFER
  zle reset-prompt
}

zle -N clear-rbuf
bindkey -M viins '^K' clear-rbuf

# 如果用了自定义补全，里面会绑定 Ctrl+E
if [[ $ENABLE_CUSTOM_COMPLETE -eq 0 ]]; then
  zle -N vi-end-of-line
  bindkey '^E' vi-end-of-line
fi

# 映射 Ctrl+A 至跳到行首
zle -N vi-beginning-of-line
bindkey -M viins '^A' vi-beginning-of-line

# 当在正常模式下按下 Ctrl + ]，打开 vi 编辑当前命令行
zle -N edit-command-line
bindkey -M vicmd '^]' edit-command-line
bindkey -M viins '^]' edit-command-line



