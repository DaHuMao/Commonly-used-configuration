#! /bin/zsh
local str=(${=2})
if (( $1 == 2 )) {
  if [[ $str[1] == '??' ]] {
    if [[ -d ${str[2]} ]] {
      eval "tree ${str[2]}"
    } else {
      eval "${FZF_FILE_HIGHLIGHTER} ${str[2]}"
    }
  } else {
    echo "command git diff ${str[2]} | diff-so-fancy --colors"
    eval "git diff ${str[2]} | diff-so-fancy --colors"
  }
} elif (( $1 == 1 )){
  echo "command git show ${str[1]} | diff-so-fancy --colors"
  eval "git show ${str[1]} | diff-so-fancy --colors"
}
