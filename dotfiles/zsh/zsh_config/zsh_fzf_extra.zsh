#!/usr/bin/env zsh
. $ZSH_CONFIG_DIR/fzf_help.zsh
[[ $- != *i* ]] && return
_fzf_compgen_path() {
  fd --type f  --no-ignore-vcs --hidden --follow --exclude .git --base-directory ${(z)1}
}

_fzf_compgen_dir() {
  fd --type d  --no-ignore-vcs --hidden --follow  --exclude .git --base-directory ${(z)1}
}

_fzf_compgen_all() {
  fd --no-ignore-vcs --hidden --follow --exclude .git ${(z)1}
}

_git_status() {
  local params=$1
  if [[ -z $params ]] {
    git status -s
  } else {
    eval "git status -s | ${params}"
  }
}

_git_log() {
  git log --color=always --pretty=format:'%C(yellow)%h%C(red) %ad%C(green)%d%C(reset) %s %C(blue)[%an]%C(reset)' --date=short

}
_git_branch() {
  git branch -a | sed 's:.*/::'
}

_select_git_edit() {
  local str_arr=(${=1})
  local mod=$2
  local remainder=$3
  local is_multi_line=$4
  if (( $is_multi_line == 0 )) {
    echo $str_arr[$remainder]
    return
  }
  local ret_arr=()
  for i ({1..$#str_arr}) {
    if (( $i % $mod == $remainder )) {
      ret_arr+=($str_arr[$i])
    }
  }
  echo $ret_arr
}

_common_selected() {
  local base_dir=$1
  local str_arr=(${(f)2})
  local res_value=""

  #去掉base_dir 最后的/
  base_dir=${base_dir%/}

  for (( i = 1; i <= ${#str_arr[@]}; i++ )); do
    if [[ -z "${str_arr[i]}" ]]; then
      continue
    fi
    res_value="$res_value $base_dir/${str_arr[i]}"
  done

  echo "$res_value"
}


_find_prompt_file() {
  local search_dir="$1"
  local search_name="$(echo "$2" | xargs)"
  local match=""

  for file in "${search_dir}"/*.prompt; do
    base_name=$(basename "$file" .prompt)
    if [[ "$base_name" == "$search_name" ]]; then
      match="$file"
      break
    fi
  done

  echo "$match"
}

export ZSH_PROMPT_DIR=$HOME/.myzsh/custom_prompt
#pre-post-example () {
#        PREDISPLAY="*** You can't edit this bit ***
#" POSTDISPLAY="
#*** Nor this bit ***"
#        #zle recursive-edit
#        #PREDISPLAY= POSTDISPLAY=
#}
#CTRL_F
typeset -g -A git_log_prefix_function_map
git_log_prefix_function_map=(
  "lg" _git_log
  "resf" _git_log
  "rehd" _git_log
  "rebase" _git_log
  "rbi" _git_log
  "revert" _git_log
)

wfxr::fzf-edit-selected-widget() {
  local search_name="$(echo "$LBUFFER" | sed 's/^ *//; s/ *$//')"
  if [[ $search_name == "" ]] {
    LBUFFER=$(cat $ZSH_PROMPT_DIR/remind_cmd | fzf $FZF_DEFAULT_COMMON_OPTS)
    zle reset-prompt
    return
  }
  local match_file=$(fd -g ${search_name}.prompt $ZSH_PROMPT_DIR)
  if [[ $match_file != "" ]] {
    LBUFFER=$(cat $match_file | fzf $FZF_DEFAULT_COMMON_OPTS)
    zle reset-prompt
    return
  }
  local tokens lbuf opt selected params cmd fzf_opt preview_tool base_dir cmd_params
  params='-'${LBUFFER##*--}
  if {is_special_opt $params} {
    lbuf=${LBUFFER%--*}
    lbuf=${lbuf/% }
  } else {
    params=''
    lbuf=$LBUFFER
  }
  if {is_dir_param $params} {
    cmd=_fzf_compgen_dir
  } else {
    cmd=_fzf_compgen_path
  }
  tokens=(${=lbuf})
  fzf_opt=($FZF_DEFAULT_COMMON_OPTS)
  preview_tool=($FZF_DEFAULT_PREVIEW_TOOL)
  cmd_params=''
  local index=0
  local is_multi_line=1
  if (($#tokens > 0)) {
    local head_cmd=$tokens[1]
    if [[ $head_cmd == 'git' ]] {
      cmd=_git_status
      if {is_git_param $params} {
        cmd_params=$(git_file_filter $params)
      } else {
        cmd_params=''
      }
      index=2
      if (( $#tokens > 1 )) {
        local token2=$tokens[2]
        if (($+git_log_prefix_function_map[$token2])) {
          cmd=$git_log_prefix_function_map[$token2]
          index=1
          is_multi_line=0
          fzf_opt+=(--tiebreak=index)
        } elif [[ $tokens[2] == 'diff' ]] || [[ $tokens[2] == 'co' ]] {
          cmd_params='grep -E "^ M|^MM|^ D"'
        } elif [[ $tokens[2] == 'cob' ]] {
          cmd=_git_branch
          index=0
          preview_tool=''
          lbuf='git co '
        }
      }
      preview_tool=(--preview "~/.myzsh/bin/git_preview.zsh $index {}")
    } else {
      setopt EXTENDED_GLOB
      cmd=_fzf_compgen_all
      if [[ $head_cmd == 'cd' || $head_cmd == 'mkdir' || $head_cmd == 'touch' || $LBUFFER == ' '#cp' '#'-r'* ]] {
        cmd_params="--type d"
      }
      if [[ ${tokens[-1]} =~ ^-d$ ]]; then
        tokens=("${tokens[@]:0:${#tokens[@]}-1}")
        cmd_params="--type d $cmd_params"
      elif [[ ${tokens[-1]} =~ ^-d[0-9]+$ ]]; then
        local number=${tokens[-1]:2}
        cmd_params="-d $number $cmd_params"
        tokens=("${tokens[@]:0:${#tokens[@]}-1}")
      fi
      local dir=${tokens[-1]/#\~/$HOME}
      base_dir='./'
      if [[ -d $dir ]] {
        base_dir=$dir
        tokens=("${tokens[@]:0:${#tokens[@]}-1}")
      }
      cmd_params="$cmd_params --base-directory $base_dir"
      lbuf=$(echo $tokens)
      preview_tool=(--preview "~/.myzsh/bin/file_dir_preview.zsh ${dir} {}")
    }
  }
  fzf_opt+=($fzf_opt $preview_tool)
  selected=$($cmd $cmd_params | fzf $fzf_opt)
  if (( $index == 0 )) || [[ -z $selected ]] {
    LBUFFER=$lbuf$(_common_selected $base_dir $selected)
  } else {
    local mod=2
    LBUFFER=$lbuf' '$(_select_git_edit $selected $mod $(($index % $mod)) $is_multi_line)
  }
  zle reset-prompt
}
zle     -N    wfxr::fzf-edit-selected-widget
bindkey '^F' wfxr::fzf-edit-selected-widget
bindkey -M viins '^F' wfxr::fzf-edit-selected-widget

# CTRL-R - Paste the selected command from history into the command line
wfxr::fzf-history-widget() {
    local selected num
    setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
    selected=$(fc -rl 1 | sort -uk2,1000 | sort -nr | fzf $FZF_DEFAULT_OPTS  --query=$LBUFFER)
    local ret=$?
    if (( $ret == 0 )) {
      local arr=(${=selected})
      LBUFFER=$arr[2,-1]
    }
    zle reset-prompt
    return ret
}
zle     -N   wfxr::fzf-history-widget
bindkey '^R' wfxr::fzf-history-widget
bindkey -M viins '^R' wfxr::fzf-history-widget

wfxr::clear_lbuf() {
  BUFFER=$RBUFFER
  CURSOR=0
  zle reset-prompt
}

zle -N wfxr::clear_lbuf
bindkey '^J' wfxr::clear_lbuf
bindkey -M viins '^J' wfxr::clear_lbuf

# 光标移动相关快捷键-----------------

# 定义 Ctrl+w 功能
function move_to_next_non_alpha() {
  local buff=$RBUFFER
  local i=1
  while [[ "$i" -le "${#buff}" ]]; do
    if [[ "${buff[$i]}" != [a-zA-Z] ]]; then
      zle forward-char
      return
    fi
    zle forward-char
    ((i++))
  done
}
zle -N move_to_next_non_alpha
bindkey "^n" move_to_next_non_alpha
bindkey -M viins "^n" move_to_next_non_alpha

# 定义 Ctrl+b 功能
function move_to_previous_non_alpha() {
  local buff=$LBUFFER
  local i=${#buff}
  while [[ "$i" -gt 0 ]]; do
    if [[ "${buff[$i]}" != [a-zA-Z0-9] ]]; then
      zle backward-char
      return
    fi
    zle backward-char
    ((i--))
  done
}
zle -N move_to_previous_non_alpha
bindkey "^b" move_to_previous_non_alpha
bindkey -M viins "^b" move_to_previous_non_alpha

#alt+up alt+down
bindkey '^[[1;3B' forward-word
bindkey -M viins '^[[1;3B' forward-word
bindkey "^[^[[B" forward-word
bindkey -M viins "^[^[[B" forward-word
bindkey '^[[1;3A' backward-word
bindkey -M viins '^[[1;3A' backward-word
bindkey "^[^[[A" backward-word
bindkey -M viins "^[^[[A" backward-word

FZF_MOVE_LAST_POS=0
FZF_MOVE_IS_RIGHT=1
wfxr::fzf_move_cursor_right() {
  sor_pos=$(($CURSOR + ${#RBUFFER} / 2))
  if [ $FZF_MOVE_IS_RIGHT -eq 0 ] && [ $CURSOR -lt $FZF_MOVE_LAST_POS ];then
    sor_pos=$(($CURSOR / 2 + $FZF_MOVE_LAST_POS / 2))
  fi
  FZF_MOVE_LAST_POS=$CURSOR
  CURSOR=$sor_pos
  FZF_MOVE_IS_RIGHT=1
}
zle -N wfxr::fzf_move_cursor_right

#alt+right
bindkey '^[[1;3C' wfxr::fzf_move_cursor_right
bindkey -M viins '^[[1;3C' wfxr::fzf_move_cursor_right
bindkey "^[^[[C" wfxr::fzf_move_cursor_right
bindkey -M viins "^[^[[C" wfxr::fzf_move_cursor_right

wfxr::fzf_move_cursor_left() {
  sor_pos=$(($CURSOR - ${#LBUFFER} / 2))
  if [ $FZF_MOVE_IS_RIGHT -eq 1 ] && [ $CURSOR -gt $FZF_MOVE_LAST_POS ];then
    sor_pos=$(($CURSOR / 2 + $FZF_MOVE_LAST_POS / 2))
  fi
  FZF_MOVE_LAST_POS=$CURSOR
  CURSOR=$sor_pos
  FZF_MOVE_IS_RIGHT=0
}
zle -N wfxr::fzf_move_cursor_left

#ctrl+left
bindkey '^[[1;3D' wfxr::fzf_move_cursor_left
bindkey -M viins '^[[1;3D' wfxr::fzf_move_cursor_left
bindkey "^[^[[D" wfxr::fzf_move_cursor_left
bindkey -M viins "^[^[[D" wfxr::fzf_move_cursor_left

