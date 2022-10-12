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

"leaderf
noremap <leader>l :<C-U><C-R>=printf("Leaderf rg --current-buffer -e %s ", expand("<cword>"))<CR><CR>
noremap <leader>L :Lines<CR>
nmap <leader>h :History <CR>
nmap <leader>t :BTags<CR>
nmap <leader>F :Files<CR>
nmap <leader>A :RA<CR>
nmap <leader>f :Rff<CR>
nmap <leader>c :Rfc<CR>
nmap <leader>v :Rfv<CR>

"nerdtre
nmap <leader>n :NERDTreeToggle<CR>



nmap <C-b> :q!<CR>
nmap <C-e> :w<CR>
noremap <C-f> :RGCword<CR>
nmap <C-p> :RG<CR>
nmap <C-d> :Gvdiffsplit<CR>
"noremap <C-p> /<C-U><C-R>=printf("%s", expand("<cword>"))<CR><CR>


"buffer-vim
nmap <C-t> :badd ~/.vim/configs/keymap.vim<CR> :buffer ~/.vim/configs/keymap.vim<CR>


"clang-format
function! Formatonsave()
  let l:formatdiff = 1
  pyf /usr/local/Cellar/clang-format/12.0.1/share/clang/clang-format.py
endfunction
"nmap <C-d> :call Formatonsave()<CR>


