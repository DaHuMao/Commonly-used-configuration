" vim: ft=vim:

call plug#begin('~/.vim/plugged')

"utils
Plug 'scrooloose/nerdtree'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'junegunn/vim-easy-align'

"markdwn preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }


Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesToggle' }

Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'


" colorscheme"
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'mhartington/oceanic-next'
Plug 'sainnhe/vim-color-forest-night'

Plug 'Yggdroot/LeaderF'

set conceallevel=2

call plug#end()


" plugin configs
source ~/.vim/configs/plug/fzf.vim
source ~/.vim/configs/plug/airline.vim

"colorscheme gruvbox
colorscheme onedark

let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

let g:mkdp_auto_close = 0
let g:WMGraphviz_output="svg"
