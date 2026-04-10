set nocompatible

source ~/.vim/env.vim
source ~/.vim/configs/common.vim
source ~/.vim/configs/utils.vim
source ~/.vim/configs/ycm.vim
source ~/.vim/configs/function_vim.vim

source ~/.vim/lua/init.lua

" fzf 一定要在init.lua之后加载,因为init.lua里面配置了fzf
" source ~/.vim/configs/fzf.vim
source ~/.vim/configs/keymap.vim

