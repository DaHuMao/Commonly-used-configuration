function! CompleteClassCpp(class_name)
  let line_num=line('.')
  let cmd_fmt=",$s/ \\(\\w*(\\)/ %s::\\1/"
  let cmd = printf(cmd_fmt, a:class_name)
  echom cmd
  execute cmd
  execute line_num
  ,$s/ *\(override\)\? *;$/;/
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

function! FindMatchCppFile() abort
  let s:file_name = bufname('')
  let s:name_arr = split(s:file_name, '\.')
  let s:arr_len = len(s:name_arr)
  if s:arr_len < 2
    throw 'unsupport file: ' . s:file_name . s:arr_len
  endif
  let s:suffix_name = s:name_arr[-1]
  let s:tar_file_prefix = join(s:name_arr[:-2], '.')
  let s:suffix_name_list = ['cc', 'c', 'cpp']
  let s:tar_file = ''
  if s:suffix_name ==# 'h'
    for ele in s:suffix_name_list
      let s:tar_file = s:tar_file_prefix . '.' . ele
      if filereadable(s:tar_file)
        break
      endif
    endfor
    if s:tar_file ==# ''
      throw 'can not find ' . s:tar_file_prefix . '.' . join(s:suffix_name_list)
    endif
  elseif index(s:suffix_name_list, s:suffix_name) != -1 
    let s:tar_file = s:tar_file_prefix . '.h'
  else
    throw 'unsupport suffix_name: ' . s:suffix_name
  endif
  echom 'read ' . s:tar_file
  execute 'e ' . s:tar_file
endfunction
command! -nargs=0 MachC call FindMatchCppFile()

"nnoremap <leader>g :set operatorfunc=GrepOperator<cr>g@
"vnoremap <leader>g :<c-u>call GrepOperator(visualmode())<cr>
"
"function! GrepOperator(type)
"    if a:type ==# 'v'
"        normal! `<v`>y
"    elseif a:type ==# 'char'
"        normal! `[v`]y
"    else
"        return
"    endif
"    echom shellescape(@@)
"endfunction
