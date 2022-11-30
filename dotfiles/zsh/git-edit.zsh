#! /bin/zsh
local str=(${=2})
if (( $1 == 2 )) {
  if [[ $str[1] == '??' ]] {
    eval "${FZF_FILE_HIGHLIGHTER} ${str[2]}"
  } else {
    eval "git diff ${str[2]} | diff-so-fancy --colors"
  }
} elif (( $1 == 1 )){
  eval "git show ${str[1]} | diff-so-fancy --colors"
}
