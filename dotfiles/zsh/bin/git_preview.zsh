#! /bin/zsh

function render_git_diff() {
  local preview_width=${FZF_PREVIEW_COLUMNS:-${COLUMNS:-120}}
  if command -v delta >/dev/null 2>&1; then
    delta --side-by-side --line-numbers --paging=never --width=${preview_width}
  elif [[ -x /opt/homebrew/bin/delta ]]; then
    /opt/homebrew/bin/delta --side-by-side --line-numbers --paging=never --width=${preview_width}
  else
    diff-so-fancy --colors
  fi
}

local str=(${=2})
if (( $1 == 2 )) {
  if [[ $str[1] == '??' ]] {
    if [[ -d ${str[2]} ]] {
      eval "tree ${str[2]}"
    } else {
      eval "${FZF_FILE_HIGHLIGHTER} ${str[2]}"
    }
  } else {
    echo "command git diff ${str[2]} | delta --side-by-side --line-numbers --paging=never --width=${FZF_PREVIEW_COLUMNS:-${COLUMNS:-120}}"
    eval "git diff ${str[2]}" | render_git_diff
  }
} elif (( $1 == 1 )){
  echo "command git show ${str[1]} | delta --side-by-side --line-numbers --paging=never --width=${FZF_PREVIEW_COLUMNS:-${COLUMNS:-120}}"
  eval "git show ${str[1]}" | render_git_diff
}
