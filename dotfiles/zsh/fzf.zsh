#source  /usr/local/opt/fzf/shell/completion.zsh
#source  /usr/local/opt/fzf/shell//key-bindings.zsh

# FZF is a general-purpose command-line fuzzy finder.
# export FZF_COMPLETION_TRIGGER=''
# bindkey '\t' fzf-completion
# bindkey '^I' "$fzf_default_completion"
FZF_FILE_HIGHLIGHTER='cat'
(( $+commands[rougify]   )) && FZF_FILE_HIGHLIGHTER='rougify'
(( $+commands[coderay]   )) && FZF_FILE_HIGHLIGHTER='coderay'
(( $+commands[highlight] )) && FZF_FILE_HIGHLIGHTER='highlight -lO ansi'
type bat &>/dev/null && FZF_FILE_HIGHLIGHTER='bat --color=always --theme=TwoDark'
export FZF_FILE_HIGHLIGHTER

(( $+commands[iconful] )) && FZF_PATH_LOC='2..' || FZF_PATH_LOC=''
export FZF_PATH_LOC

# FZF: default
(( $+commands[ag]   )) && FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g "" 2>/dev/null'
(( $+commands[fd]   )) && FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null'
export FZF_DEFAULT_COMMAND

FZF_DEFAULT_COMMON_OPTS=(
  --border
  --height 80%
  --extended
  --ansi
  --reverse
  --cycle
  --multi
  --bind ctrl-b:preview-half-page-up,ctrl-n:preview-half-page-down
  --bind ctrl-u:half-page-up
  --bind ctrl-d:half-page-down
  --bind ctrl-p:select-all,ctrl-r:toggle-all
  --bind ctrl-/:toggle-preview,alt-w:toggle-preview-wrap
  --bind "ctrl-y:execute-silent(ruby -e 'puts ARGV' {+} | pbcopy)+abort"
  --bind 'alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
  --preview-window right:50%:hidden
)
FZF_DEFAULT_PREVIEW_TOOL=(--preview "${FZF_FILE_HIGHLIGHTER} {}")
FZF_DEFAULT_OPTS=($FZF_DEFAULT_COMMON_OPTS $FZF_DEFAULT_PREVIEW_TOOL)
export FZF_DEFAULT_COMMON_OPTS
export FZF_DEFAULT_PREVIEW_TOOL
export FZF_DEFAULT_OPTS
#--preview \"($FZF_FILE_HIGHLIGHTER {} || $FZF_DIR_HIGHLIGHTER {}) 2>/dev/null | head -200\"
#--bind ctrl-s:toggle-sort

# FZF: Ctrl - T
FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
(( $+commands[iconful] )) && FZF_CTRL_T_COMMAND="$FZF_CTRL_T_COMMAND | iconful -f"
export FZF_CTRL_T_COMMAND
FZF_CTRL_T_OPTS="
--preview \"($FZF_FILE_HIGHLIGHTER {$FZF_PATH_LOC} || $FZF_DIR_HIGHLIGHTER {$FZF_PATH_LOC}) 2>/dev/null | head -200\"
--bind 'enter:execute(echo {$FZF_PATH_LOC})+abort'
--bind 'alt-e:execute($EDITOR {$FZF_PATH_LOC} >/dev/tty </dev/tty)'
--bind \"ctrl-y:execute-silent(ruby -e 'puts ARGV' {+$FZF_PATH_LOC} | pbcopy)+abort\"
--preview-window right:50%
"
export FZF_CTRL_T_OPTS


# FZF: Ctrl - R
FZF_CTRL_R_OPTS="
--preview 'echo {}'
--preview-window 'down:2:wrap'
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--header 'Press CTRL-Y to copy command into clipboard'
--exact
--expect=ctrl-x
"
export FZF_CTRL_R_OPTS

# FZF: Alt - C
(( $+commands[fd]   )) && FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git 2>/dev/null'
(( $+commands[blsd] )) && FZF_ALT_C_COMMAND='blsd $dir | grep -v "^.$"'
(( $+commands[iconful] )) && FZF_ALT_C_COMMAND="$FZF_ALT_C_COMMAND | iconful -d"
export FZF_ALT_C_COMMAND
FZF_DIR_HIGHLIGHTER='ls -l --color=always'
(( $+commands[tree] )) && FZF_DIR_HIGHLIGHTER='tree -CtrL2'
(( $+commands[exa]  )) && FZF_DIR_HIGHLIGHTER='exa --color=always -TL2'
export FZF_DIR_HIGHLIGHTER
export FZF_ALT_C_OPTS="
--exit-0
--bind 'enter:execute(echo {$FZF_PATH_LOC})+abort'
--preview '($FZF_DIR_HIGHLIGHTER {$FZF_PATH_LOC}) | head -200 2>/dev/null'
--preview-window=right:50%
"

# FZF: Alt - E
FZF_ALT_E_COMMAND="$FZF_DEFAULT_COMMAND"
(( $+commands[iconful] )) && FZF_ALT_E_COMMAND="$FZF_ALT_E_COMMAND | iconful -f"
export FZF_ALT_E_COMMAND
FZF_ALT_E_OPTS="
--preview \"($FZF_FILE_HIGHLIGHTER {$FZF_PATH_LOC} || $FZF_DIR_HIGHLIGHTER {$FZF_PATH_LOC}) 2>/dev/null | head -200\"
--bind 'alt-e:execute($EDITOR {$FZF_PATH_LOC} >/dev/tty </dev/tty)'
--bind \"ctrl-y:execute-silent(ruby -e 'puts ARGV' {+$FZF_PATH_LOC} | pbcopy)+abort\"
--preview-window right:50%
"
export FZF_ALT_E_OPTS

