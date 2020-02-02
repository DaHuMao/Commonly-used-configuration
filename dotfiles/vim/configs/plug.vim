" vim: ft=vim:

call plug#begin('~/.vim/plugged')

"utils
Plug 'scrooloose/nerdtree'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'danro/rename.vim'

Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'junegunn/vim-easy-align'
"Plug 'easymotion/vim-easymotion'
Plug 'rizzatti/dash.vim'

Plug 'rust-lang/rust.vim'

"markdwn preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }


" vim-slash provides a set of mappings for enhancing in-buffer search experience in Vim.
Plug 'junegunn/vim-slash' 

Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesToggle' }

Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'


" colorscheme"
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'mhartington/oceanic-next'
Plug 'sainnhe/vim-color-forest-night'

" improve indent and syntax hightlight for these filetypes
Plug 'uarun/vim-protobuf'
Plug 'uber/prototool', { 'rtp':'vim/prototool' }
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml',                 {'for': 'yaml'}
Plug 'andrewstuart/vim-kubernetes',      {'for': 'yaml'}
Plug 'ekalinin/Dockerfile.vim',          {'for': 'dockerfile'}
Plug 'elzr/vim-json',                    {'for': 'json'}
Plug 'ap/vim-css-color',                 {'for': 'css'}
Plug 'vim-scripts/awk.vim',              {'for': 'awk'}
Plug 'bfrg/vim-cpp-modern'
Plug 'derekwyatt/vim-scala'
Plug 'fatih/vim-go'

" git
Plug 'mhinz/vim-signify' 
Plug 'tpope/vim-fugitive'

Plug 'xieyu/vim-codenote'
Plug 'xieyu/vim-cd'

Plug 'wannesm/wmgraphviz.vim'

call plug#end()


" plugin configs
"source ~/.vim/configs/plug/language-client.vim
source ~/.vim/configs/plug/fzf.vim
source ~/.vim/configs/plug/airline.vim
source ~/.vim/configs/plug/devicons.vim
source ~/.vim/configs/plug/coc.vim

colorscheme gruvbox
"colorscheme onedark
let g:rustfmt_autosave = 1

let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

let g:mkdp_auto_close = 0
let g:WMGraphviz_output="svg"
abbre gs GraphvizShow
abbre gc GraphvizCompile
