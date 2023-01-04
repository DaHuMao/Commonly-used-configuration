" use space as map leader
let mapleader = ","
let g:mapleader = ","

"insert mode 命令加强
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-b> <ESC>Bi
inoremap <C-w> <ESC>Wa
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-h> <Left>
inoremap <A-'> {}<Left><CR><CR><Up><Tab>

" split window jump
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" 命令行模式增强，ctrl - a到行首， -e 到行尾
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" Go to home and end using capitalized directions
noremap H ^
noremap L $
noremap J <PageDown>zz
noremap K <PageUp>zz

"Keep search pattern at the center of the screen."
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

"copy and paste from clipboard
nmap Y "+y
nmap P "+p
nmap <c-p> "+


"fzf-vim
noremap <leader>l :Rbufferc<CR>
noremap <leader>L :Rbuffer<CR>
noremap <leader>h :History <CR>
noremap <leader>t :BTags<CR>
noremap <leader>f :Rfile ./<CR>
noremap <leader>A :RG<CR>
noremap <leader>F :Rfc<CR>
noremap <leader>i :Ric<CR>
noremap <leader>c :Rcc<CR>
noremap <leader>v :Rvc<CR>
noremap <leader>b :Buffers<CR>

"windows
noremap <leader>zz :MaximizerToggle<CR>
noremap <leader>zl :ResizerRight<CR>
noremap <leader>zh :ResizerLeft<CR>
noremap <leader>zk :ResizerUp<CR>
noremap <leader>zj :ResizerDown<CR>

noremap <A-Up> :resize -3<CR>
noremap <A-Down> :resize +3<CR>
noremap <A-Left> :vertical resize -5<CR>
noremap <A-Right> :vertical resize +5<CR>


"nerdtree
noremap <leader>n :NERDTreeToggle<CR>

noremap <C-b> :q!<CR>
noremap <C-e> :w<CR>

" terminal
let g:floaterm_width = 0.8
let g:floaterm_height = 0.8
tnoremap <A-/> <C-\><C-n>:FloatermToggle base_float_term<CR>
nnoremap <A-/> :FloatermToggle base_float_term<CR>

"C++
noremap <A-m> :MachC<CR>

"快速打开zsh vim配置文件
noremap <C-t> :e ~/.vim/configs/keymap.vim<CR>
command! -nargs=0 Vsh :e ~/.zshrc
command! -nargs=0 Vsc :source ~/.vimrc

"autocmd
autocmd BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif





