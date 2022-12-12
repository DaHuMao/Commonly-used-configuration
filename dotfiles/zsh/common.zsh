# History
export HISTFILE="$HOME/.zsh_history" # History file
export HISTSIZE=100000               # History size in memory
export SAVEHIST=1000000              # The number of histsize
export LISTMAX=50                    # The size of asking history
setopt EXTENDED_HISTORY              # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY            # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY               # Share history between all sessions.
setopt HIST_IGNORE_SPACE             # Do not record an entry starting with a space.
setopt HIST_REDUCE_BLANKS            # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY                   # Do not execute immediately upon history expansion.
setopt HIST_BEEP                     # Beep when accessing nonexistent history.

export TERM=screen-256color
export HOMEBREW_NO_AUTO_UPDATE=true
