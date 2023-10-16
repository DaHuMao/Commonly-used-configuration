function! CompleteClassCpp(class_name, line_count = 0)
  let s:line_num=line('.')
  let s:end_line='$'
  echom a:line_count
  if a:line_count > 0
    let s:end_line = s:line_num + a:line_count
  endif
  let s:cmd_fmt=",%ss/ \\(\\w*(\\)/ %s::\\1/"
  let s:cmd = printf(s:cmd_fmt, s:end_line, a:class_name)
  echom s:cmd
  execute s:cmd
  execute s:line_num
  let s:cmd_fmt=',%ss/ *\(override\)\? *;$/;/'
  let s:cmd = printf(s:cmd_fmt, s:end_line)
  execute s:cmd
  execute s:line_num
  let s:cmd_fmt = ',%ss/)\(.*\);$/)\1 {\rreturn;\r}\r/'
  let s:cmd = printf(s:cmd_fmt, s:end_line)
  execute s:cmd
endfunction

"clang-format
function! Formatonsave(flag)
  if a:flag == 1
    let l:lines="all"
  else
    let l:formatdiff = 1
  endif
  py3f /usr/local/Cellar/clang-format/16.0.1/share/clang/clang-format.py
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
      let s:tmp_file = s:tar_file_prefix . '.' . ele
      if filereadable(s:tmp_file)
        let s:tar_file = s:tmp_file
        break
      endif
    endfor
    if s:tar_file ==# ''
      throw 'can not find ' . s:tar_file_prefix . '.' . join(s:suffix_name_list)
    endif
  elseif index(s:suffix_name_list, s:suffix_name) != -1
    let s:tar_file = s:tar_file_prefix . '.h'
    if filereadable(s:tar_file) == 0
      throw 'can not find ' . s:tar_file
    endif
  else
    throw 'unsupport suffix_name: ' . s:suffix_name
  endif
  echom 'read ' . s:tar_file
  execute 'e ' . s:tar_file
endfunction

let s:cur_win_width = 0
let s:cur_win_height = 0
let s:resize_win_flag = 1
function MaxOrMinWindows()
  if s:resize_win_flag > 0
    let s:cur_win_width = winwidth('%')
    let s:cur_win_height = winheight('%')
    let s:resize_win_flag = 0
    execute 'resize ' . 200
    execute 'vertical resize ' . 200
    echom s:cur_win_height . ' ' . s:cur_win_width
  else
    let s:resize_win_flag = 1
    execute 'resize ' . s:cur_win_height
    execute 'vertical resize ' . s:cur_win_width
  endif
endfunction


" make abc_def_hg to AbcDefHg
function GetClassName(file_name)
  " Split the string into parts by '_' or '.'
  let s:parts = split(a:file_name, '_')

  " Capitalize each part
  for i in range(len(s:parts)) " Exclude the last part (suffix)
    let s:parts[i] = toupper(s:parts[i][0]) . tolower(s:parts[i][1:])
  endfor

  " Join the parts into a new string (excluding the last part)
  return join(s:parts[:-1], '')
endfunction

function CppWriteHead(start_index)
  " Step 1: get the relative path with filename
  let s:filepath = expand('%')

  " Step 2: Split the string into an array using the './' character
  let s:parts = split(s:filepath, '[./]')
  if len(s:parts) < 2
    throw "invalid file_name: " . s:filepath
  endif

  " Step 3: Create a new string based on the array content
  let s:newfilepath = ""
  if len(s:parts) > a:start_index
    let s:newfilepath = join(s:parts[a:start_index:], '_')
  else
    let s:newfilepath = join(s:parts, '_')
  endif

  " Step 4: Convert the string to uppercase
  let s:newfilepath = toupper(s:newfilepath) . '_'

  " Step 5: Replace '-' with '_'
  let s:newfilepath = substitute(s:newfilepath, "-", "_", "g")


  " Step 6: Get class_name
  let s:class_name = GetClassName(s:parts[-2])

  execute "normal i#ifndef " . s:newfilepath . "\<esc>"
  execute "normal o#define " . s:newfilepath . "\<esc>"
  execute "normal oclass " . s:class_name . " {\<CR>\<BS> public:"
  execute "normal o\<esc>Hi  " . s:class_name . "() = default;\<esc>"
  execute "normal o\<esc>Hi  ~" . s:class_name . "() = default;\<CR>};\<esc>"
  execute "normal o#endif // " . s:newfilepath . "\<esc>"
endfunction

function CppWriteCC()
  let s:filename = expand('%:t')
  let s:parts = split(s:filename, '\.')
  if len(s:parts) < 1
    throw "invalid file_name: " . s:filename
  endif
  let s:class_name = GetClassName(s:parts[0])
  call CompleteClassCpp(s:class_name)
  call Formatonsave(1)
endfunction

function! SafeWriteFunc()
    if &modified
        silent! Gdiff
        if &diff == 0
            set nodiff
            write
        else
            set nodiff
        endif
    endif
endfunction


command! -nargs=* Cc call CompleteClassCpp(<f-args>)
command! -nargs=0 MachC call FindMatchCppFile()
command! -nargs=1 Cpph call CppWriteHead(<q-args>)
command! -nargs=0 Cppc call CppWriteCC()

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
