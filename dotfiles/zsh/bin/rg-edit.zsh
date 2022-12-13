#! /bin/zsh
local str_array=(${(s/:/)1})
local file_name=$str_array[1]
local line_num=$str_array[2]
bat --color=always --highlight-line $line_num --theme=gruvbox-dark $file_name
