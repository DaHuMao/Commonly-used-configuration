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
  git for-each-ref --format='%(refname:short)' refs/heads/
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
  "show" _git_log
  "git_show_file" _git_log
)

typeset -g -A normal_cmd_map
normal_cmd_map=(
"remove_branch" _git_branch
"remove_branchs" _git_branch
)

wfxr::fzf-plain-selected() {
  local str_arr=(${(f)1})
  local res_value=""
  local item

  for item in "${str_arr[@]}"; do
    [[ -z $item ]] && continue
    res_value="$res_value $item"
  done

  echo "$res_value"
}

wfxr::fzf-reset-context() {
  typeset -g _wfxr_fzf_lbuf="$1"
  typeset -g _wfxr_fzf_params=""
  typeset -g _wfxr_fzf_cmd="_fzf_compgen_all"
  typeset -g _wfxr_fzf_cmd_params=""
  typeset -g _wfxr_fzf_base_dir="./"
  typeset -g _wfxr_fzf_preview_dir="./"
  typeset -g _wfxr_fzf_result_mode="path"
  typeset -g _wfxr_fzf_git_index=0
  typeset -g _wfxr_fzf_is_multi_line=1
  typeset -ga _wfxr_fzf_opt
  _wfxr_fzf_opt=($FZF_DEFAULT_COMMON_OPTS)
  typeset -ga _wfxr_fzf_preview_tool
  _wfxr_fzf_preview_tool=()
}

wfxr::fzf-handle-prompt-prefix() {
  local search_name="$(echo "$LBUFFER" | sed 's/^ *//; s/ *$//')"
  local match_file=""

  if [[ -z $search_name ]] {
    LBUFFER=$(cat $ZSH_PROMPT_DIR/remind_cmd | fzf $FZF_DEFAULT_COMMON_OPTS)
    zle reset-prompt
    return 0
  }

  match_file=$(fd -g ${search_name}.prompt $ZSH_PROMPT_DIR)
  if [[ -n $match_file ]] {
    LBUFFER=$(cat $match_file | fzf $FZF_DEFAULT_COMMON_OPTS)
    zle reset-prompt
    return 0
  }

  return 1
}

wfxr::fzf-parse-special-param() {
  local raw_buffer="$1"
  local params='-'${raw_buffer##*--}

  if is_special_opt $params; then
    _wfxr_fzf_params=$params
    _wfxr_fzf_lbuf=${raw_buffer%--*}
    _wfxr_fzf_lbuf=${_wfxr_fzf_lbuf/% }
  else
    _wfxr_fzf_params=''
    _wfxr_fzf_lbuf=$raw_buffer
  fi
}

wfxr::fzf-setup-normal-context() {
  local head_cmd="$1"
  (($+normal_cmd_map[$head_cmd])) || return 1

  _wfxr_fzf_cmd=$normal_cmd_map[$head_cmd]
  _wfxr_fzf_result_mode='plain'
  _wfxr_fzf_preview_tool=()
  return 0
}

wfxr::fzf-setup-git-context() {
  local tokens=("$@")
  local use_git_preview=1

  _wfxr_fzf_cmd=_git_status
  _wfxr_fzf_cmd_params=''
  _wfxr_fzf_result_mode='git'
  _wfxr_fzf_git_index=2
  _wfxr_fzf_is_multi_line=1

  if is_git_param $_wfxr_fzf_params; then
    _wfxr_fzf_cmd_params=$(git_file_filter $_wfxr_fzf_params)
  fi

  if (( $#tokens > 1 )) {
    local token2=$tokens[2]
    if (($+git_log_prefix_function_map[$token2])) {
      _wfxr_fzf_cmd=$git_log_prefix_function_map[$token2]
      _wfxr_fzf_git_index=1
      _wfxr_fzf_is_multi_line=0
      _wfxr_fzf_opt+=(--tiebreak=index)
    } elif [[ $token2 == 'diff' ]] || [[ $token2 == 'co' ]] {
      _wfxr_fzf_cmd_params='grep -E "^ M|^MM|^ D"'
    } elif [[ $token2 == 'cob' ]] {
      _wfxr_fzf_cmd=_git_branch
      _wfxr_fzf_result_mode='plain'
      _wfxr_fzf_lbuf='git co '
      use_git_preview=0
    }
  }

  if (( use_git_preview )); then
    _wfxr_fzf_preview_tool=(--preview "~/.myzsh/bin/git_preview.zsh $_wfxr_fzf_git_index {}")
  else
    _wfxr_fzf_preview_tool=()
  fi
}

wfxr::fzf-dir-command() {
  local tokens=("$@")
  local head_cmd=$tokens[1]

  [[ $head_cmd == 'cd' || $head_cmd == 'mkdir' || $head_cmd == 'touch' ]] && return 0
  [[ $head_cmd == 'cp' && $#tokens -gt 1 && $tokens[2] == '-r' ]] && return 0
  return 1
}

wfxr::fzf-setup-path-context() {
  setopt EXTENDED_GLOB

  local tokens=("$@")
  local dir='./'
  local base_dir='./'
  local cmd_params=''

  _wfxr_fzf_cmd=_fzf_compgen_all
  _wfxr_fzf_result_mode='path'

  if is_dir_param $_wfxr_fzf_params || wfxr::fzf-dir-command "${tokens[@]}"; then
    cmd_params="--type d"
  fi

  if (( $#tokens > 0 )); then
    if [[ ${tokens[-1]} =~ ^-d$ ]]; then
      tokens=("${tokens[@]:0:${#tokens[@]}-1}")
      cmd_params="--type d $cmd_params"
    elif [[ ${tokens[-1]} =~ ^-d[0-9]+$ ]]; then
      local number=${tokens[-1]:2}
      cmd_params="-d $number $cmd_params"
      tokens=("${tokens[@]:0:${#tokens[@]}-1}")
    fi
  fi

  if (( $#tokens > 0 )); then
    local last_token=${tokens[-1]}
    local head=${last_token[1,-2]}
    local tail=${last_token[-1]}

    [[ -z $head ]] && head='./'
    local expanded_head=${head/#\~/$HOME}

    if [[ $tail == <-> ]] && [[ -d $expanded_head ]]; then
      cmd_params="-d $tail $cmd_params"
      base_dir=$expanded_head
      dir=$base_dir
      tokens=("${tokens[@]:0:${#tokens[@]}-1}")
    else
      dir=${tokens[-1]/#\~/$HOME}
      if [[ -d $dir ]]; then
        base_dir=$dir
        tokens=("${tokens[@]:0:${#tokens[@]}-1}")
      fi
    fi
  fi

  _wfxr_fzf_base_dir=$base_dir
  _wfxr_fzf_preview_dir=$dir
  _wfxr_fzf_cmd_params="$cmd_params --base-directory $base_dir"
  _wfxr_fzf_lbuf=$(echo $tokens)
  _wfxr_fzf_preview_tool=(--preview "~/.myzsh/bin/file_dir_preview.zsh ${dir} {}")
}

wfxr::fzf-apply-selected() {
  local selected="$1"

  [[ -z $selected ]] && return

  case $_wfxr_fzf_result_mode {
    (plain)
      LBUFFER=$_wfxr_fzf_lbuf$(wfxr::fzf-plain-selected "$selected")
      ;;
    (git)
      local mod=2
      LBUFFER=$_wfxr_fzf_lbuf' '$(_select_git_edit "$selected" $mod $(($_wfxr_fzf_git_index % $mod)) $_wfxr_fzf_is_multi_line)
      ;;
    (*)
      LBUFFER=$_wfxr_fzf_lbuf$(_common_selected $_wfxr_fzf_base_dir "$selected")
      ;;
  }
}

wfxr::fzf-run-selection() {
  local selected=""
  local fzf_opt=("${_wfxr_fzf_opt[@]}")

  (( ${#_wfxr_fzf_preview_tool[@]} > 0 )) && fzf_opt+=("${_wfxr_fzf_preview_tool[@]}")
  selected=$($_wfxr_fzf_cmd $_wfxr_fzf_cmd_params | fzf $fzf_opt)
  wfxr::fzf-apply-selected "$selected"
}

wfxr::fzf-edit-selected-widget() {
  local tokens
  local head_cmd=''

  wfxr::fzf-handle-prompt-prefix && return

  wfxr::fzf-reset-context "$LBUFFER"
  wfxr::fzf-parse-special-param "$LBUFFER"
  tokens=(${=_wfxr_fzf_lbuf})

  if (( $#tokens > 0 )); then
    head_cmd=$tokens[1]
    if wfxr::fzf-setup-normal-context "$head_cmd"; then
      :
    elif [[ $head_cmd == 'git' ]]; then
      wfxr::fzf-setup-git-context "${tokens[@]}"
    else
      wfxr::fzf-setup-path-context "${tokens[@]}"
    fi
  else
    wfxr::fzf-setup-path-context
  fi

  wfxr::fzf-run-selection
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
