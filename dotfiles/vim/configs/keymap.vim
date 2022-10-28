noremap ; :

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

" Leaderf
noremap <leader>k :<C-U><C-R>=printf("Leaderf rg --current-buffer -e %s ", expand("<cword>"))<CR><CR>

"fzf-vim
noremap <leader>l :BLinesCword<CR>
noremap <leader>L :BLines<CR>
nmap <leader>h :History <CR>
nmap <leader>t :BTags<CR>
nmap <leader>F :Rfile<CR>
nmap <leader>A :RG<CR>
nmap <leader>f :Rff<CR>
nmap <leader>c :Rfc<CR>
nmap <leader>v :Rfv<CR>
nmap <leader>b :Buffers<CR>

"nerdtre
nmap <leader>n :NERDTreeToggle<CR>

nmap <C-b> :q!<CR>
nmap <C-e> :w<CR>
noremap <C-f> :RGCword<CR>
nmap <C-p> :RG<CR>
nmap <C-a> :Rac<CR>
nmap <C-d> :Gvdiffsplit<CR>
"noremap <C-p> /<C-U><C-R>=printf("%s", expand("<cword>"))<CR><CR>

"快速打开zsh vim配置文件
nmap <C-t> :e ~/.vim/configs/keymap.vim<CR>
command! -nargs=0 Vsh :e ~/.zshrc

function CompleteClassCpp(class_name)
  let line_num=line('.')
  let cmd_fmt=",$s/ \\(\\w*(\\)/ %s::\\1/"
  let cmd = printf(cmd_fmt, a:class_name)
  echom cmd
  execute cmd
  execute line_num
  ,$s/\(override\)\?//
  execute line_num
  ,$s/ *;$/;/
  execute line_num
  ,$s/)\(.*\);$/)\1 {\r\r}\r/
endfunction

command! -nargs=1 Cc call CompleteClassCpp(<q-args>)



"clang-format
function! Formatonsave(flag)
  if a:flag == 1
    let l:lines="all"
  else
    let l:formatdiff = 1
  endif
  py3f /usr/local/Cellar/clang-format/14.0.6/share/clang/clang-format.py
endfunction
command! -nargs=1 Fmt call Formatonsave(<q-args>)
"autocmd BufWritePre *.h,*.cc,*.cpp call Formatonsave()
"nmap <C-d> :call Formatonsave()<CR>


