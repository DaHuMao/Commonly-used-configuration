noremap ; :
cnoremap <C-a> <Home>
cnoremap <C-e> <end>

" use space as map leader
let mapleader = ","
let g:mapleader = ","


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

"FZF
nmap <leader>t :FZF<CR>
nmap <leader>l :<C-U><C-R>=printf("BLines %s", expand("<cword>"))<CR><CR>
nmap <leader>L :BLines<CR>
nmap <leader>h :History <CR>
nmap <leader>r :BTags<CR>
"nmap <leader>f :execute "Rg "."<C-r><C-w>"<CR>
nmap <leader>f ::LeaderfFile<CR>
nmap <leader>p :Wd<CR>

"nerdtre
nmap <leader>n :NERDTreeToggle<CR>



nmap <C-b> :q!<CR>
nmap <C-e> :w<CR>
nmap <C-o> :wq<CR>
nmap <leader>F :Rg<CR>
noremap <C-f> :<C-U><C-R>=printf("Leaderf! rg -e %s -g '*.{h,cpp,cc,m,mm}' ./", expand("<cword>"))<CR><CR>
noremap <C-p> /<C-U><C-R>=printf("%s", expand("<cword>"))<CR><CR>


"buffer-vim
nmap <C-n> :bn<CR>
nmap <C-d> :bdelete<CR>
nmap <C-t> :badd ~/.vimrc<CR> :buffer ~/.vimrc<CR>
