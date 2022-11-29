#! /bin/zsh
local str=(${=2})
if (( $1 == 2 )) {
  eval "git diff ${str[$1]} | diff-so-fancy --colors"
} elif (( $1 == 1 )){
  eval "git show ${str[$1]} | diff-so-fancy --colors"
}
