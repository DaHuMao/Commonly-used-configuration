#!/usr/bin/env zsh
. $ZSH_CONFIG_DIR/color.zsh
# 自定义图标
if [[ -z $CUSTOM_PROMPT_SYMBOL ]]; then
  CUSTOM_PROMPT_SYMBOL='->'
fi

if [[ -z $CUSTOM_TIME ]]; then
  CUSTOM_TIME='%H:%M'
fi

# 使得 PROMPT_SUBST 生效，以便能在 PROMPT 中使用 $()
setopt PROMPT_SUBST
# 设置颜色
autoload -U colors && colors

# 自定义函数，以便显示 Git 状态
git_prompt() {
  local branch=""
  local log_message=""
  local git_dir=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -f $git_dir/.git/rebase-merge/head-name ]; then
    branch="REBASE|$(basename $(cat $git_dir/.git/rebase-merge/head-name))"
    log_message=" ${fg_gray}$(git show --oneline -s HEAD 2>/dev/null)${fg_reset_color}"
  else
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  fi
  if [ -n "$branch" ]; then
    echo " On: [${fg_orange}$branch${reset_color}]$log_message"
  fi
}

git_branch_str=""

# 初始自定义图标设置为紫色，如果发生错误则会变化
custom_icon="${fg_purple}${CUSTOM_PROMPT_SYMBOL}${fg_reset_color}"

# 预处理函数
typeset -g COMMAND_START_TIME
COMMAND_START_TIME=$(get_current_millisecond)
function before_accept_line() {
  if [[ $ENABLE_PROMPT_USED_TIME -eq 1 ]]; then
    COMMAND_START_TIME=$(get_current_millisecond)
  fi
  LAST_COMMAND=${BUFFER}
}

# 绑定到 accept-line 事件
function before_accept_line_hook_and_accept_line() {
    # 调用预处理函数
    before_accept_line
    # 然后继续执行实际的 accept-line
    zle .accept-line
}

zle -N before_accept_line_hook_and_accept_line
# 将 Enter 键绑定到自定义函数
bindkey '^M' before_accept_line_hook_and_accept_line

ONE_DAY_MS=86400000
ONE_HOUR_MS=3600000
ONE_MINUTE_MS=60000
ONE_SECOND_MS=1000

# 更新提示符函数
update_prompt() {
  PROMPT=""
  if [[ $ENABLE_PROMPT_TIME -eq 1 ]]; then
    local custom_time="${fg_light_yellow}$(get_time_strftime $CUSTOM_TIME)${fg_reset_color}"
    PROMPT="${custom_time} "
  fi
  PROMPT+="In ${fg_blue}%~${fg_reset_color}"
  if [[ $ENABLE_PROMPT_GIT -eq 1 ]]; then
    ENABLE_PROMPT_LAZE_GIT=0
    PROMPT+=$(git_prompt)
  fi

  if [[ $ENABLE_PROMPT_LAZE_GIT -eq 1 ]]; then
    if [[ -z $git_branch_str ]]; then
      git_branch_str='$(git_prompt)'
    else
      # 获取最后一条命令并去除前导空格
      local last_command=${LAST_COMMAND## }
      #last_command是否以git 开头
      if [[ $last_command == git* ]]; then
        # 优化模式匹配
        case "$last_command" in git\ checkout*|git\ co*|git\ switch*|git\ rb*|git\ rebase*)
          git_branch_str='$(git_prompt)'
          ;;
      esac
      fi
    fi
    PROMPT+=$git_branch_str
  fi

  local error_status=""
  # 如果上一条命令执行失败，图标变成红色，并显示错误状态
  if [ $LAST_CMD_EXIT_STATUS -ne 0 ]; then
    error_status="%{${fg_red}%} x %{${fg_reset_color}%}"
    custom_icon="%{${fg_red}%}${CUSTOM_PROMPT_SYMBOL}%{${fg_reset_color}%} %"
  else
    # 如果没有错误，图标保持紫色
    custom_icon="%{${fg_purple}%}${CUSTOM_PROMPT_SYMBOL}%{${fg_reset_color}%} %"
  fi

  if [[ $ENABLE_PROMPT_USED_TIME -eq 1 ]]; then
    local end_time=$(get_current_millisecond)
    used_time=$((end_time - COMMAND_START_TIME))
    if [[ $ENABLE_USED_TIME_DISPLAY_DETAIL -eq 1 ]]; then
      if [[ $used_time -gt $ONE_DAY_MS ]]; then
        #取余数，然后除以一小时的毫秒数
        used_time_hours=$(( (used_time % ONE_DAY_MS) / ONE_HOUR_MS))
        used_time_day=$((used_time / ONE_DAY_MS))
        used_time="${used_time_day}d ${used_time_hours}h"
      elif [[ $used_time -gt $ONE_HOUR_MS ]]; then
        #取余数，然后除以一分钟的毫秒数
        used_time_minutes=$(( (used_time % ONE_HOUR_MS) / ONE_MINUTE_MS))
        used_time_hours=$((used_time / ONE_HOUR_MS))
        used_time="${used_time_hours}h ${used_time_minutes}m"
      elif [[ $used_time -gt $ONE_MINUTE_MS ]]; then
        #取余数，然后除以一秒的毫秒数
        used_time_seconds=$(( (used_time % ONE_MINUTE_MS) / ONE_SECOND_MS))
        used_time_minutes=$((used_time / ONE_MINUTE_MS))
        used_time="${used_time_minutes}m ${used_time_seconds}s"
      elif [[ $used_time -gt ONE_SECOND_MS ]]; then
        used_time_ms=$((used_time % ONE_SECOND_MS))
        used_time_seconds=$((used_time / ONE_SECOND_MS))
        used_time="${used_time_seconds}s ${used_time_ms}ms"
      else
        used_time="${used_time}ms"
      fi
    else
      used_time="${used_time}ms"
    fi
    PROMPT+=" ${fg_light_yellow}${used_time}${fg_reset_color}"
  fi

  # 设置第二行提示符（图标）
  PROMPT+=${error_status}$'\n'" $custom_icon "
}

# 在每次命令执行完后调用 update_prompt 函数
if [[ ! "${precmd_functions[@]}" =~ "update_prompt" ]]; then
  precmd_functions+=(update_prompt)
fi
