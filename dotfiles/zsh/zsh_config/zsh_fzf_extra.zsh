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
  # 这是一个 ZLE widget（见文件末尾 `zle -N` + `bindkey ^F`），用于：
  # 1) 当命令行为空时，提供“常用命令/提示词”列表快速粘贴；
  # 2) 当命令行内容匹配某个 `.prompt` 文件名时，从该 prompt 文件里挑选一条插入；
  # 3) 否则，根据当前 LBUFFER（光标左侧内容）推断“你可能想补全/选择”的内容：
  #    - 普通场景：用 `fd` 搜索文件/目录/任意条目，然后用 fzf 选择并追加到命令行
  #    - git 场景：`git status -s`/`git log`/`git branch` 的结果里选目标，并把文件名/commit hash 追加到命令行
  #
  # 约定：支持在命令末尾追加 `--<opt>` 作为本 widget 的“特殊参数”，例如：
  # - `... --d`     表示只选目录（`is_dir_param`）
  # - `git ... --m` 表示 git 文件过滤（`is_git_param`），会转换成 grep 规则筛选 `git status -s` 输出
  #   这里的解析规则是：取最后一次出现的 `--` 之后的内容并补上前导 `-`，例如 `--m` -> `-m`
  local search_name="$(echo "$LBUFFER" | sed 's/^ *//; s/ *$//')"
  if [[ $search_name == "" ]] {
    # 命令行为空：从 remind_cmd（一个纯文本列表）里选一条，直接替换当前 LBUFFER。
    LBUFFER=$(cat $ZSH_PROMPT_DIR/remind_cmd | fzf $FZF_DEFAULT_COMMON_OPTS)
    zle reset-prompt
    return
  }
  local match_file=$(fd -g ${search_name}.prompt $ZSH_PROMPT_DIR)
  if [[ $match_file != "" ]] {
    # 命令行不为空，但“整行内容”刚好等于某个 prompt 名称：
    # 例如你输入 `docker`，存在 `$ZSH_PROMPT_DIR/docker.prompt`，则从该文件里再选一条。
    LBUFFER=$(cat $match_file | fzf $FZF_DEFAULT_COMMON_OPTS)
    zle reset-prompt
    return
  }
  local tokens lbuf opt selected params cmd fzf_opt preview_tool base_dir cmd_params
  # 解析“特殊参数”：
  # - 如果用户在末尾输入 `--x`（例如 `--m` / `--d`），这里会得到 params="-x"
  # - 否则 params 置空，整个 LBUFFER 作为 lbuf 参与后续解析
  params='-'${LBUFFER##*--}
  if {is_special_opt $params} {
    # 有特殊参数时，把 `--...` 从 LBUFFER 中移除，避免它影响 token 拆分和实际命令
    lbuf=${LBUFFER%--*}
    lbuf=${lbuf/% }
  } else {
    params=''
    lbuf=$LBUFFER
  }
  # 根据特殊参数决定默认是补全“目录”还是“文件”（不传 `--d` 时默认文件）
  if {is_dir_param $params} {
    cmd=_fzf_compgen_dir
  } else {
    cmd=_fzf_compgen_path
  }
  # tokens：把光标左侧命令按空白拆分成数组（例如 "git diff" -> (git diff)）
  tokens=(${=lbuf})
  # fzf 的通用配置来自 `dotfiles/zsh/zsh_config/fzf.zsh`
  fzf_opt=($FZF_DEFAULT_COMMON_OPTS)
  preview_tool=($FZF_DEFAULT_PREVIEW_TOOL)
  cmd_params=''
  # index：用于告诉 preview 脚本“要预览的是第几个字段/或某种模式”
  # - index=0：表示选择结果直接当作路径追加
  # - git status 场景下会用 index=2（输出是两列：状态 + 文件名）
  local index=0
  # is_multi_line：当 cmd 输出是一行一个条目时为 1；当希望只取某一列（比如 git log 的 hash）时为 0
  local is_multi_line=1
  if (($#tokens > 0)) {
    local head_cmd=$tokens[1]
    if [[ $head_cmd == 'git' ]] {
      # ---- git 场景 ----
      # 默认展示 `git status -s`，并通过特殊参数（--n/--m/--a/--d）筛选文件状态。
      cmd=_git_status
      if {is_git_param $params} {
        cmd_params=$(git_file_filter $params)
      } else {
        cmd_params=''
      }
      # `git status -s` 默认两列：<status> <path>，所以后面取第 2 列（index=2）
      index=2
      if (( $#tokens > 1 )) {
        local token2=$tokens[2]
        if (($+git_log_prefix_function_map[$token2])) {
          # 例如 `git lg` / `git rebase`：改为展示 git log，并从选中的那一行里取 commit hash
          cmd=$git_log_prefix_function_map[$token2]
          index=1
          is_multi_line=0
          fzf_opt+=(--tiebreak=index)
        } elif [[ $tokens[2] == 'diff' ]] || [[ $tokens[2] == 'co' ]] {
          # `git diff` / `git co`：只关心“已修改/已删除”等状态的文件
          cmd_params='grep -E "^ M|^MM|^ D"'
        } elif [[ $tokens[2] == 'cob' ]] {
          # `git cob`：切分支，用 `git branch -a` 的结果供选择，并把命令前缀改成 `git co `
          cmd=_git_branch
          index=0
          preview_tool=''
          lbuf='git co '
        }
      }
      # git 预览：交给自定义脚本处理（通常会根据 index 判断预览文件还是 commit）
      preview_tool=(--preview "~/.myzsh/bin/git_preview.zsh $index {}")
    } else {
      # ---- 非 git 场景：使用 fd 在 base_dir 下搜索，再用 fzf 选择 ----
      setopt EXTENDED_GLOB
      cmd=_fzf_compgen_all
      if [[ $head_cmd == 'cd' || $head_cmd == 'mkdir' || $head_cmd == 'touch' || $LBUFFER == ' '#cp' '#'-r'* ]] {
        # 这些命令通常只需要目录（例如 cd/mkdir/touch/cp -r 目标目录）
        cmd_params="--type d"
      }
      if [[ ${tokens[-1]} =~ ^-d$ ]]; then
        # 支持末尾额外加一个 `-d`：强制只选目录（与 `--d` 不同，这里是 fd 的参数风格）
        tokens=("${tokens[@]:0:${#tokens[@]}-1}")
        cmd_params="--type d $cmd_params"
      elif [[ ${tokens[-1]} =~ ^-d[0-9]+$ ]]; then
        # 支持 `-dN`：作为 fd 的深度（max-depth）参数
        local number=${tokens[-1]:2}
        cmd_params="-d $number $cmd_params"
        tokens=("${tokens[@]:0:${#tokens[@]}-1}")
      fi

      # 新规则（按“末位字符”判断）：
      # 把最后一个 token 拆成两段：
      # - head = 第 1 个字符到倒数第 2 个字符（可能为空；为空时强制为 `./`）
      # - tail = 最后 1 个字符
      # 若 tail 是数字且 head 是目录：命中规则 -> 在该目录下做 `fd -d <tail>` 深度搜索。
      # 例：`xx xxx A/B1` -> head=A/B, tail=1 -> 在 `A/B` 下 `fd -d 1 ...`
      # 例：`xx xxx 1`    -> head=./,  tail=1 -> 在当前目录 `fd -d 1 ...`
      local dir='./'
      base_dir='./'
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
          # 目录/深度信息已经编码在 last_token 里，把它从命令前缀移除
          tokens=("${tokens[@]:0:${#tokens[@]}-1}")
        else
          # 未命中新规则：沿用原逻辑，若最后一个 token 是目录则作为 base_dir
          dir=${tokens[-1]/#\~/$HOME}
          if [[ -d $dir ]] {
            base_dir=$dir
            tokens=("${tokens[@]:0:${#tokens[@]}-1}")
          }
        fi
      fi
      # fd 从 base_dir 起搜索，返回相对路径；后面会用 `_common_selected` 拼回 base_dir
      cmd_params="$cmd_params --base-directory $base_dir"
      lbuf=$(echo $tokens)
      # 文件/目录预览：交给自定义脚本（一般会做 `bat`/`ls` 之类的预览）
      # 注意：预览脚本的第一个参数是“基准目录”。
      # - 原逻辑：通常取最后一个 token（若它是目录则等同于 base_dir）
      # - 新规则：裸数字/目录+数字时会强制令 dir=base_dir，避免预览跑偏
      preview_tool=(--preview "~/.myzsh/bin/file_dir_preview.zsh ${dir} {}")
    }
  }
  # 将预览配置拼进 fzf 选项。
  # 注意：这里写成 `fzf_opt+=($fzf_opt $preview_tool)` 会把当前 fzf_opt 自己再追加一遍；
  # 这是现有逻辑，先不改行为，只加注释说明。
  fzf_opt+=($fzf_opt $preview_tool)
  # 运行候选生成命令 -> fzf 选择（支持 --multi），selected 可能包含多行结果
  selected=$($cmd $cmd_params | fzf $fzf_opt)
  if (( $index == 0 )) || [[ -z $selected ]] {
    # 普通场景：把选择到的相对路径用 base_dir 补全成绝对/相对（取决于 base_dir）并追加到 lbuf
    LBUFFER=$lbuf$(_common_selected $base_dir $selected)
  } else {
    # git 场景：从 fzf 的选择结果中提取“想要的字段”并追加
    # - git status：选择多行时输出会被扁平化成 (status1 file1 status2 file2 ...)，取偶数位得到文件名列表
    # - git log：只取第一列（commit hash）
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
