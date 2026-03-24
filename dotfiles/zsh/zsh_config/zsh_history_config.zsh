# History
export HISTFILE="$HOME/.zsh_history" # History file
export HISTSIZE=5000                 # History size in memory
export SAVEHIST=10000                # The number of histsize
export LISTMAX=50                    # The size of asking history
setopt EXTENDED_HISTORY              # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY            # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY                 # Share history between all sessions.
setopt HIST_IGNORE_SPACE             # Do not record an entry starting with a space.
setopt HIST_REDUCE_BLANKS            # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY                   # Do not execute immediately upon history expansion.
setopt HIST_BEEP                     # Beep when accessing nonexistent history.
# 删除重复的历史记录条目
setopt HIST_EXPIRE_DUPS_FIRST
# 忽略重复的历史记录
setopt HIST_IGNORE_DUPS
# 合并多个终端会话中的历史记录
setopt SHARE_HISTORY
