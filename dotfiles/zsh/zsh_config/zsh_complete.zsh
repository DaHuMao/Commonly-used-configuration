
export ZSH_COMPETE_DIR=$MYZSH_DIR/zsh_complete
if [[ ! -d "${ZSH_COMPETE_DIR}" ]]; then
  mkdir -p "${ZSH_COMPETE_DIR}"
fi
zsh $ZSH_CONFIG_DIR/zsh_complete_build_checker.zsh
log_and_return_on_error "zsh_complete_build_checker.zsh failed" || return 1

# 加载自定义补全模块
module_path+=($ZSH_COMPETE_DIR)
zmodload libcustom_zsh_complete
log_and_return_on_error "zmodload libcustom_zsh_complete failed" || return 1

MIN_UPDATE_INTERVAL=30
LAST_UPDATE=0
CURRENT_ARRAY_INDEX=0
LAST_BTN_IS_UP_OR_DOWN=0
SEARCHED_HISTORY_ARRAY=()
SUGGESTION=""
BUFFER_WITHOUT_SPACE=""

# 启动或更新定时器
function update_timer {
  POSTDISPLAY=""
    local now=$(get_current_millisecond)
    local elapsed=$(( now - LAST_UPDATE ))
    if (( elapsed >= MIN_UPDATE_INTERVAL )); then
        LAST_UPDATE=$now
        complete_suggestion
    fi
}
. $ZSH_CONFIG_DIR/color.zsh
autoload -U colors && colors
if [[ "$terminfo[colors]" -ge 256 ]]; then
    grey=$'%{\e[38;5;244m%}'
    reset_color=$'%{\e[0m%}'
else
fi
grey=$'%{\e[90m%}'
reset_color=$'%{\e[0m%}'

# 定义高亮样式
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
# 应用高亮以显示建议
_apply_suggestion_highlight() {
    if (( ${#POSTDISPLAY} )); then
    fi
}

# 获取建议的函数
function complete_suggestion() {
  #RPS1="%F{244}${last_key}%f"
  # 获取最近一次按键
  local last_key="${KEYS[-1]}"
  # 判断按键是否是我们要过滤掉的按键
  case "$last_key" in
    $'\e[C'|$'\e[D'|$'\t'|$'\b'|$'\x7f')  # Tab、Backspace 和 Delete 键
      local cur_time=$(get_current_millisecond)
      return
      ;;
  esac

  if [[ $CURSOR -ne ${#BUFFER} ]]; then
    return
  fi

  BUFFER_WITHOUT_SPACE="${BUFFER#"${BUFFER%%[! ]*}"}"

  # BUFFER_WITHOUT_SPACE 可能为空
  if [ ! -z "$BUFFER_WITHOUT_SPACE" ]; then
    # 获取建议
    zsh_complete_query $CURRENT_PID $BUFFER_WITHOUT_SPACE
    local suggestion=$COMPLETE_REPLY
    if [ -z "$suggestion" ]; then
      return
    fi
    #RPS1="%F{244}${suggestion}%f"
    SUGGESTION=${suggestion#*${BUFFER_WITHOUT_SPACE}}
    render_suggestion
  fi
}

render_suggestion() {
  if [[ -n $SUGGESTION ]]; then
    BUFFER=$BUFFER_WITHOUT_SPACE
    POSTDISPLAY="${SUGGESTION}"
    local start=${#BUFFER}
    local end=$(( ${#BUFFER} + ${#POSTDISPLAY} ))
    region_highlight+=("$start $end $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE")
    #zle reset-prompt
  fi
}

# 在每次重新绘制行之前进行检查
function zle-line-pre-redraw() {
  if (( ${#KEYS[@]} >= 3 )); then
    local key_sequence="${(j::)KEYS[@]: -3:3}"  # 明确截取最后3个元素
  else
    local key_sequence="${(j::)KEYS[@]}"  # 不足3个时拼接全部
  fi
  case "$key_sequence" in
    $'\e[A'|$'\eOA'|$'\e[B'|$'\eOB')  # 上键（标准VT100/xterm序列）
      return
      ;;
    $'\e[C'|$'\eOC'|$'\e[D'|$'\eOD')  # 右键
      return
      ;;
  esac
  LAST_BTN_IS_UP_OR_DOWN=0
  update_timer
}
zle -N zle-line-pre-redraw

function complete_buffer {
  LBUFFER="${LBUFFER}${POSTDISPLAY}"
  POSTDISPLAY=""
  region_highlight=()
  #zle reset-prompt
}

function complete_buffer_or_move() {
  if [[ -n $POSTDISPLAY ]]; then
    complete_buffer
  else
    zle forward-char
  fi
}

function to_end_buffer() {
  if [[ -n $POSTDISPLAY ]]; then
    complete_buffer
  else
    zle end-of-line
  fi
}

zle -N to_end_buffer
bindkey '^E' to_end_buffer
bindkey -M viins '^E' to_end_buffer

# 右键
zle -N complete_buffer_or_move
bindkey '^[[C' complete_buffer_or_move
bindkey -M viins '^[[C' complete_buffer_or_move

zle-line-finish() {
  # 获取当前命令输入内容
  local cur_cmd=$(echo "$BUFFER")
  POSTDISPLAY=""
  region_highlight=()
  #zle reset-prompt
}

zle -N zle-line-finish

render_searched_history() {
  if (( $CURRENT_ARRAY_INDEX == 0 )); then
    return
  fi
  SUGGESTION=${SEARCHED_HISTORY_ARRAY[CURRENT_ARRAY_INDEX]}
  SUGGESTION=${SUGGESTION#*${BUFFER_WITHOUT_SPACE}}
  #RPS1="%F{244}${POSTDISPLAY}----${suggestion}%f"
  render_suggestion
}

LAST_LBUFFER_CONTENT=""
# 上键处理函数
handle_up_key() {
  BUFFER_WITHOUT_SPACE="${BUFFER#"${BUFFER%%[! ]*}"}"
  # 如果行内容为空，调用默认的上键函数
  if [[ -z $BUFFER_WITHOUT_SPACE ]] || [[ $LAST_BTN_IS_UP_OR_DOWN -eq 1 ]]; then
    POSTDISPLAY=""
    zle up-line-or-history
    LAST_BUFFER_CONTENT=""
    LAST_BTN_IS_UP_OR_DOWN=1
    return
  fi
  if [[ "$BUFFER_WITHOUT_SPACE" != "$LAST_BUFFER_CONTENT" ]]; then
    LAST_BUFFER_CONTENT=$BUFFER_WITHOUT_SPACE
    CURRENT_ARRAY_INDEX=0
    zsh_complete_query_array $CURRENT_PID "$LAST_BUFFER_CONTENT"
    SEARCHED_HISTORY_ARRAY=(${(f)COMPLETE_REPLY})
    #echo "history_array_str: $COMPLETE_REPLY" >> ./tmp_debug_log.txt
    #for ele in "${SEARCHED_HISTORY_ARRAY[@]}"; do
    #  echo "ele: $ele" >> ./tmp_debug_log.txt
    #done
    #echo "------------------------------- ===" >> ./tmp_debug_log.txt
  fi
  #如果数组小于等于1，直接返回
  if (( ${#SEARCHED_HISTORY_ARRAY[@]} <= 1 )); then
    POSTDISPLAY=""
    zle up-line-or-history
    LAST_BUFFER_CONTENT=""
    return
  fi
  if (( $CURRENT_ARRAY_INDEX == 0 )); then
    CURRENT_ARRAY_INDEX=2
  else
    CURRENT_ARRAY_INDEX=$((CURRENT_ARRAY_INDEX + 1))
  fi
  if (( $CURRENT_ARRAY_INDEX > ${#SEARCHED_HISTORY_ARRAY[@]} )); then
    CURRENT_ARRAY_INDEX=1
  fi
  render_searched_history
}
zle -N custom-up-key handle_up_key
bindkey '^[[A' custom-up-key  # 上键

# 下键处理函数
handle_down_key() {
  # 如果行内容为空，调用默认的下键函数
  if [[ $LAST_BTN_IS_UP_OR_DOWN -eq 1 ]]; then
    POSTDISPLAY=""
    zle down-line-or-history
  else
    if (( ${#SEARCHED_HISTORY_ARRAY[@]} <= 1 )); then
      POSTDISPLAY=""
      zle down-line-or-history
      return
    fi
    if (( $CURRENT_ARRAY_INDEX > 1 )); then
      CURRENT_ARRAY_INDEX=$((CURRENT_ARRAY_INDEX - 1))
      render_searched_history
    else
      CURRENT_ARRAY_INDEX=${#SEARCHED_HISTORY_ARRAY[@]}
    fi
  fi
}

# 自定义按键绑定
zle -N custom-up-key handle_up_key
zle -N custom-down-key handle_down_key

bindkey '^[[A' custom-up-key  # 上键
bindkey '^[[B' custom-down-key  # 下键
bindkey -M viins '^[[A' custom-up-key  # 上键
bindkey -M viins '^[[B' custom-down-key  # 下键

reset_value() {
  LAST_CMD_EXIT_STATUS=$?
  SEARCHED_HISTORY_ARRAY=()
  CURRENT_ARRAY_INDEX=0
  LAST_BTN_IS_UP_OR_DOWN=0
  LAST_BUFFER_CONTENT=""
  SUGGESTION=""
  BUFFER_WITHOUT_SPACE=""
  #if [[ $LAST_CMD_EXIT_STATUS -ne 0 ]]; then
  #  return
  #fi
  if [[ $LAST_COMMAND =~ [^[:space:]] ]]; then
    zsh_complete_insert $CURRENT_PID "$LAST_COMMAND"
  fi
}

if [[ ! $precmd_functions[@] =~ reset_value ]]; then
  precmd_functions+=(reset_value)
fi
# 定义 TRAPEXIT 钩子函数
zsh_exit() {
  zsh_complete_termina_exit $CURRENT_PID
}

# 确保此 config 成为 Zsh 的配置文件的一部分
autoload -U add-zsh-hook
add-zsh-hook zshexit zsh_exit
