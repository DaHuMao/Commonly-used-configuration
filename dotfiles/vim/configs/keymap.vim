" use space as map leader
let mapleader = ","
let g:mapleader = ","

"insert mode 命令加强
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-b> <ESC>Bi
inoremap <C-w> <ESC>Wa
inoremap <C-f> <ESC>f
inoremap <m-f> <ESC>F

"Treat long lines as break lines (useful when moving around in them)
"se swap之后，同物理行上线直接跳
nnoremap k gk
nnoremap gk k
nnoremap j gj
nnoremap gj j

" split window jump
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" 命令行模式增强，ctrl - a到行首， -e 到行尾
cnoremap <C-j> <t_kd>
cnoremap <C-k> <t_ku>
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

"nerdtree
noremap <leader>n :NERDTreeToggle<CR>

noremap <C-b> :q!<CR>
noremap <C-e> :w<CR>
noremap <C-f> :RGCword<CR>
noremap <C-p> :RG<CR>
noremap <C-a> :Rac<CR>

" terminal
let g:floaterm_width = 0.8
let g:floaterm_height = 0.8
tnoremap <A-/> <C-\><C-n>:FloatermToggle base_float_term<CR>
nnoremap <A-/> :FloatermToggle base_float_term<CR>
"noremap <C-p> /<C-U><C-R>=printf("%s", expand("<cword>"))<CR><CR>

"C++
noremap <M-m> :MachC<CR>

"快速打开zsh vim配置文件
noremap <C-t> :e ~/.vim/configs/keymap.vim<CR>
command! -nargs=0 Vsh :e ~/.zshrc
command! -nargs=0 Vsc :source ~/.vimrc







