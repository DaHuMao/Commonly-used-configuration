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
inoremap <C-a> <Home>
inoremap <C-e> <End>

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


"fzf-vim
noremap <leader>l :Rbufferc<CR>
noremap <leader>L :Rbuffer<CR>
noremap <leader>h :History <CR>
noremap <leader>t :BTags<CR>
noremap <leader>F :Rfile ./<CR>
noremap <leader>A :RG<CR>
noremap <leader>f :Rfc<CR>
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
noremap <C-d> :Gvdiffsplit<CR>
"noremap <C-p> /<C-U><C-R>=printf("%s", expand("<cword>"))<CR><CR>

"快速打开zsh vim配置文件
noremap <C-t> :e ~/.vim/configs/keymap.vim<CR>
command! -nargs=0 Vsh :e ~/.zshrc
command! -nargs=0 Vsc :source ~/.vimrc

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
  py3f /usr/local/Cellar/clang-format/15.0.4/share/clang/clang-format.py
endfunction
command! -nargs=1 Fmt call Formatonsave(<q-args>)
"autocmd BufWritePre *.h,*.cc,*.cpp call Formatonsave()
"nmap <C-d> :call Formatonsave()<CR>

nnoremap <leader>g :set operatorfunc=GrepOperator<cr>g@
vnoremap <leader>g :<c-u>call GrepOperator(visualmode())<cr>

function! GrepOperator(type)
    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif
    echom shellescape(@@)
endfunction


