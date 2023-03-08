#! /bin/zsh
local str_array=(${(s/:/)1})
local file_name=$str_array[1]
local line_num=$str_array[2]
if (($# > 1)) {
  file_name=$2
  line_num=$str_array[1]
}
local pre_line_num=$((line_num - 15))
if (( $pre_line_num < 0 )) {
  pre_line_num=0
}
bat --color=always \
--highlight-line $line_num --theme=gruvbox-dark \
--line-range $pre_line_num:$((line_num +15)) \
$file_name
