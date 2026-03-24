"clang-format
function! s:Formatonsave(flag)
  " 设置路径
  let l:clang_format_path = $CLANG_FORMAT_PATH

  " 检查指定路径是否存在 clang-format.py
  if !filereadable(clang_format_path)
    let l:clang_format_path = expand('$HOME/.vim/clang-format.py')
  endif

  " 再次检查 $HOME/.vim 目录下是否存在 clang-format.py
  if !filereadable(l:clang_format_path)
    " 如果找不到，则下载 clang-format.py 文件
    echo 'clang-format.py not found, downloading...'
    let l:curl_cmd = 'curl -fLo ' . l:clang_format_path . ' --create-dirs https://raw.githubusercontent.com/llvm/llvm-project/main/clang/tools/clang-format/clang-format.py'
    execute 'silent !' . l:curl_cmd

    " 检查下载是否成功
    if !filereadable(l:clang_format_path)
      throw 'Failed to download clang-format.py'
      return
    else
      echo 'clang-format.py downloaded to ' . l:clang_format_path
    endif
  end

  " 执行格式化
  if a:flag == 1
    let l:lines="all"
  else
    let l:formatdiff = 1
  endif

  " 调用 Python 格式化脚本
  execute 'py3file ' . l:clang_format_path
endfunction


command! -nargs=1 Fmt call s:Formatonsave(<q-args>)
"autocmd BufWritePre *.h,*.cc,*.cpp call s:Formatonsave()
"nmap <C-d> :call s:Formatonsave()<CR>

function s:FindMatchCppFile() abort
  let l:file_name = bufname('')
  let l:name_arr = split(l:file_name, '\.')
  let l:arr_len = len(l:name_arr)
  if l:arr_len < 2
    throw 'unsupport file: ' . l:file_name . l:arr_len
  endif
  let l:suffix_name = l:name_arr[-1]
  let l:tar_file_prefix = join(l:name_arr[:-2], '.')
  let l:suffix_name_list = ['cc', 'c', 'cpp', 'mm', 'm']
  let l:h_suffix_name_list = ['h', 'hpp']

  " Get the base filename without path
  let l:base_name = fnamemodify(l:file_name, ':t:r')
  let l:current_dir = fnamemodify(l:file_name, ':h')

  " Determine target suffix list based on current file type
  let l:target_suffix_list = []
  if index(l:h_suffix_name_list, l:suffix_name) != -1
    let l:target_suffix_list = l:suffix_name_list
  elseif index(l:suffix_name_list, l:suffix_name) != -1
    let l:target_suffix_list = l:h_suffix_name_list
  else
    throw 'unsupport suffix_name: ' . l:suffix_name
  endif

  " Search in current directory first
  let l:tar_file = ''
  for ele in l:target_suffix_list
    let l:tmp_file = l:current_dir . '/' . l:base_name . '.' . ele
    if filereadable(l:tmp_file)
      let l:tar_file = l:tmp_file
      break
    endif
  endfor

  " If not found in current directory, use fd to search in parent and parent's parent directories
  if l:tar_file ==# ''
    let l:search_dirs = [l:current_dir . '/..', l:current_dir . '/../..']
    for l:search_dir in l:search_dirs
      for ele in l:target_suffix_list
        let l:target_filename = l:base_name . '.' . ele
        let l:fd_cmd = 'fd "' . l:target_filename . '" "' . l:search_dir . '" -t f --max-depth 3'
        let l:fd_result = systemlist(l:fd_cmd)
        if len(l:fd_result) > 0
          " Use the first match
          let l:tar_file = l:fd_result[0]
          break
        endif
      endfor
      if l:tar_file !=# ''
        break
      endif
    endfor
  endif

  if l:tar_file ==# ''
    throw 'can not find ' . l:base_name . '.' . join(l:target_suffix_list, '/')
  endif

  echom 'read ' . l:tar_file
  execute 'e ' . l:tar_file
endfunction

let s:cur_win_width = 0
let s:cur_win_height = 0
let s:resize_win_flag = 1
function s:MaxOrMinWindows()
  if l:resize_win_flag > 0
    let l:cur_win_width = winwidth('%')
    let l:cur_win_height = winheight('%')
    let l:resize_win_flag = 0
    execute 'resize ' . 200
    execute 'vertical resize ' . 200
    echom l:cur_win_height . ' ' . l:cur_win_width
  else
    let l:resize_win_flag = 1
    execute 'resize ' . l:cur_win_height
    execute 'vertical resize ' . l:cur_win_width
  endif
endfunction


" make abc_def_hg to AbcDefHg
function s:GetClassName(file_name)
  " Split the string into parts by '_' or '.'
  let l:parts = split(a:file_name, '_')

  " Capitalize each part
  for i in range(len(l:parts)) " Exclude the last part (suffix)
    let l:parts[i] = toupper(l:parts[i][0]) . tolower(l:parts[i][1:])
  endfor

  " Join the parts into a new string (excluding the last part)
  return join(l:parts[:-1], '')
endfunction

function s:CppWriteHead(start_index, namesapce = "")
  " Step 1: get the relative path with filename
  let l:filepath = expand('%')

  " Step 2: Split the string into an array using the './' character
  if IsWindows()
    let l:parts = split(l:filepath, '[.\\]')
  else
    let l:parts = split(l:filepath, '[./]')
  endif
  if len(l:parts) < 2
    throw "invalid file_name: " . l:filepath
  endif

  " Step 3: Create a new string based on the array content
  let l:newfilepath = ""
  if len(l:parts) > a:start_index
    let l:newfilepath = join(l:parts[a:start_index:], '_')
  else
    let l:newfilepath = join(l:parts, '_')
  endif

  " Step 4: Convert the string to uppercase
  let l:newfilepath = toupper(l:newfilepath) . '_'

  " Step 5: Replace '-' with '_'
  let l:newfilepath = substitute(l:newfilepath, "-", "_", "g")


  " Step 6: Get class_name
  let l:class_name = s:GetClassName(l:parts[-2])

  execute "normal i#ifndef " . l:newfilepath . "\<esc>"
  execute "normal o#define " . l:newfilepath . "\<esc>"
  if a:namesapce != ""
    execute "normal onamespace " . a:namesapce . " {\<esc>"
  endif
  execute "normal oclass " . l:class_name . " {\<CR>\<BS> public:"
  execute "normal o\<esc>Hi  " . l:class_name . "() = default;\<esc>"
  execute "normal o\<esc>Hi  ~" . l:class_name . "() = default;\<esc>"
  execute "normal o\<CR>private:\<CR>};\<esc>"
  execute "normal o#endif // " . l:newfilepath . "\<esc>"
  if a:namesapce != ""
    execute "normal O} // namespace " . a:namesapce . "\<esc>"
  endif
  call s:Formatonsave(1)
endfunction

function SafeWriteFunc()
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

function s:CppHeaderProcess()
  let l:line_num = line('.')
  execute '%s/ virtual //'
  execute '%s/= 0/override/'
endfunction

command! -nargs=0 MachC call s:FindMatchCppFile()
command! -nargs=* Cpph call s:CppWriteHead(<f-args>)
command! -nargs=0 CpphProcess call s:CppHeaderProcess()

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
