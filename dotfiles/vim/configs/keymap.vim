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
noremap <leader>L :Leaderf rg --current-buffer<CR>
nmap <leader>h :History <CR>
nmap <leader>r :source ~/.vimrc<CR>
nmap <leader>F :Rgf<CR>
noremap <C-f> :call CustomGrep("*.{h,c,cc,cpp,m,mm}", ['::%', "#define %", "class %", "struct % ", "%;"])<CR>
noremap <leader>m :call CustomGrep("*.{h,c,cc,cpp,m,mm}", [])<CR>
nmap <leader>f ::LeaderfFile<CR>
nmap <leader>p :Wd<CR>

"nerdtre
nmap <leader>n :NERDTreeToggle<CR>

"git
nnoremap <Leader>s :<C-u>call gitblame#echo()<CR>

nmap <C-b> :q!<CR>
nmap <C-e> :w<CR>
"nmap <C-o> :wq<CR>
"noremap <C-p> /<C-U><C-R>=printf("%s", expand("<cword>"))<CR><CR>


"buffer-vim
nmap <C-n> :bn<CR>
nmap <C-d> :bdelete<CR>
nmap <C-t> :badd ~/.vimrc<CR> :buffer ~/.vimrc<CR>

"ycm 
let g:ycm_error_symbol = '>>'
let g:ycm_warning_symbol = '>*'
nnoremap <leader>gl :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gf :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration<CR>


