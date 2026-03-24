let g:RG_DEFAULT_CONFIG="rg --column --line-number --no-heading --color=always --max-columns 250 --max-filesize 500K"
"let g:FZF_COLOR=['--color=preview-bg:#223344,border:#778899,header:#ed8796', '--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796', '--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6', '--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796']
let g:FZF_DEFAULT_OPTS=['--ansi', '--layout=reverse', '--info=inline',
                       \'--bind', 'ctrl-/:toggle-preview', '--bind',
                       \'ctrl-b:preview-half-page-up,ctrl-n:preview-half-page-down']
let s:Spec = {'options': g:FZF_DEFAULT_OPTS }
let s:default_windows = {'width': 0.9, 'height': 0.9}
let s:default_preview = 'bat --color=always --theme=gruvbox-dark {1} --highlight-line {2}'
" Files + devicons
function s:Fzf_dev()
  let l:fzf_files_options = '--preview "rougify {2..-1} | head -'.&lines.'"'

  function! s:files()
    let l:files = split(system($FZF_DEFAULT_COMMAND), '\n')
    return l:prepend_icon(l:files)
  endfunction

  function s:prepend_icon(candidates)
    let l:result = []
    for l:candidate in a:candidates
      let l:filename = fnamemodify(l:candidate, ':p:t')
      let l:icon = WebDevIconsGetFileTypeSymbol(l:filename, isdirectory(l:filename))
      call add(l:result, printf('%s %s', l:icon, l:candidate))
    endfor

    return l:result
  endfunction

  function! s:edit_file(item)
    let l:pos = stridx(a:item, ' ')
    let l:file_path = a:item[pos+1:-1]
    execute 'silent e' l:file_path
  endfunction

  call fzf#run({
        \ 'source': <sid>files(),
        \ 'sink':   function('s:edit_file'),
        \ 'options': '-m ' . l:fzf_files_options,
        \ 'down':    '40%' })
endfunction

function s:edit_file(file_name)
  execute 'silent e ' . a:file_name
endfunction

function s:edit_rg_file(strr)
  echom a:strr
  let l:arr = split(a:strr, ':')
  let l:index = 0
  if filereadable(l:arr[0]) != 0
    execute 'silent e ' . l:arr[0]
    let l:index = 1
  endif
  execute 'normal!' . l:arr[l:index] . 'G'
  execute 'normal!' . '^' . l:arr[l:index + 1] . 'l'
endfunction

function s:fzf_for_rg(source, edit_fun_name, preview_script)
  let l:preview_script_str = s:default_preview
  if a:preview_script != ''
    let l:preview_script_str = a:preview_script
  endif
  let l:fzf_opt = g:FZF_DEFAULT_OPTS + ['--delimiter', ':',
        \ '--preview', l:preview_script_str,
        \ '--preview-window', 'up,70%,border-bottom,hidden,wrap,+{2}+3/3,~3']
  call fzf#run({'source': a:source,
        \ 'options': l:fzf_opt,
        \ 'window': s:default_windows,
  \ 'sink': function(a:edit_fun_name)})
endfunction

function s:RipgrepFzf(query, file_suffix, exclude_cmd)
  let l:str = "--smart-case -e ''"
  if strlen(a:query) > 0
    let l:str = ' -F -- ' .  a:query
  endif
  if a:file_suffix != ''
    let l:command_fmt = g:RG_DEFAULT_CONFIG.' -g "*.{%s}" %s %s || true'
  else
    let l:command_fmt = g:RG_DEFAULT_CONFIG.' %s %s %s || true'
  endif
  let l:initial_command = printf(l:command_fmt, a:file_suffix, a:exclude_cmd, l:str)
  call s:fzf_for_rg(l:initial_command, 's:edit_rg_file', '')
endfunction

function s:RipgrepFzfAll(...)
  echo 'argl:' a:000
  let l:is_regexp = ' -F '
  let l:command_fmt = g:RG_DEFAULT_CONFIG
  if a:1 == 0
    let l:command_fmt = 'rg --column --line-number --no-heading --color=always --no-ignore-vcs --max-columns 250 --max-filesize 250K'
  endif
  if a:0 > 1 && a:2 != ''
    let l:is_regexp = ' -e '
  endif
  if a:0 > 3 && a:4 != '0'
    let l:command_fmt .= " -g '*.{" . a:4 . "}'"
  endif
  if a:0 > 4 && a:5 != '0'
    let l:command_fmt .= " -g  '!*.{" . a:5 . "}'"
  endif
  if a:0 > 6
    let l:command_fmt .= ' ' . a:6
  endif
  if a:0 > 2
    let l:command_fmt .= l:is_regexp . "-- " .  a:3
  else
    let l:command_fmt .= " --smart-case " + l:is_regexp + " ''"
  endif
  let l:command_fmt .= ' || true'
  call s:fzf_for_rg(l:command_fmt, 's:edit_rg_file', '')
endfunction

function s:RipgrepFzfFunction(func_name, enable_smart_case)
  let l:smart_case = ''
  if a:enable_smart_case > 0
    let l:smart_case = ' --smart-case '
  endif
  let l:str1='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:func_name . '\('
  let l:str2='^ *' . a:func_name . '\('
  let l:command_fmt = g:RG_DEFAULT_CONFIG . l:smart_case . ' -g "*.{h}" -e "%s|%s" || true'
  let l:initial_command = printf(l:command_fmt, l:str1, l:str2)
  call s:fzf_for_rg(l:initial_command, 's:edit_rg_file', '')
endfunction

function s:RipgrepFzfClassDefine(class_name, enable_smart_case)
  let l:smart_case = ''
  if a:enable_smart_case > 0
    let l:smart_case = ' --smart-case '
  endif
  let l:str1="#define *" . a:class_name
  let l:str2="using *"  . a:class_name . ' *='
  let l:str3="class .*"  . a:class_name . ' '
  let l:str4="struct .*"  . a:class_name . ' '
  let l:str5="enum *"  . a:class_name . ' '
  let l:str6="typedef .* " . a:class_name . ' *;'
  let l:gstr1="class .*"  . a:class_name . ' *;'
  let l:gstr2="struct .*"  . a:class_name . ' *;'
  let l:command_fmt = g:RG_DEFAULT_CONFIG  . l:smart_case . ' -g "*.{h}" -e "%s|%s|%s|%s|%s|%s" || true | rg -v "%s|%s"'
  let l:initial_command = printf(l:command_fmt, l:str1, l:str2, l:str3, l:str4, l:str5, l:str6, l:gstr1, l:gstr2)
  call s:fzf_for_rg(l:initial_command, 's:edit_rg_file', '')
endfunction

function s:RipgrepFzfValDefine(val_name, enable_smart_case)
  let l:smart_case = ''
  if a:enable_smart_case > 0
    let l:smart_case = ' --smart-case '
  endif
  let l:str1='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:val_name . ' *;'
  let l:str2='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:val_name . ' *='
  let l:str3='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:val_name . ' .*;'
  let l:command_fmt = g:RG_DEFAULT_CONFIG . l:smart_case . ' -g "*.{h,cpp,cc,c,m,mm,java}" -e "%s|%s|%s"|| true'
  let l:initial_command = printf(l:command_fmt, l:str1, l:str2, l:str3)
  call s:fzf_for_rg(l:initial_command, 's:edit_rg_file', '')
endfunction

function s:RipgrepFzfFunctionRef(func_name, enable_smart_case)
  let l:smart_case = ''
  if a:enable_smart_case > 0
    let l:smart_case = ' --smart-case '
  endif
  let l:str1=' *[a-zA-Z0-9_]+::' . a:func_name . '\('
  let l:str2='^ *[a-zA-Z0-9_]+  *' . a:func_name . '.*\{'
  let l:command_fmt = g:RG_DEFAULT_CONFIG . l:smart_case . ' -g "*.{cpp,cc,c}" -e "%s|%s" || true'
  let l:initial_command = printf(l:command_fmt, l:str1, l:str2)
  call s:fzf_for_rg(l:initial_command, 's:edit_rg_file', '')
endfunction


function s:FindFile(file_path, is_all)
  if empty(a:file_path)
    let l:file_path = '.'
  else
    let l:file_path = a:file_path
  endif
  let l:command_fmt='fd --type f --hidden --follow --exclude .o --exclude .git '
  if a:is_all > 0
    let l:command_fmt = l:command_fmt . '--no-ignore'
  endif
  let l:command_fmt = l:command_fmt . ' . ' . l:file_path
  call s:fzf_for_rg(l:command_fmt, 's:edit_file', 'bat --color=always --theme=gruvbox-dark {}')
endfunction

function s:FindWordInCurBuffer(str)
  let l:cur_file = bufname("%")
  if IsWindows()
    let l:cur_file = substitute(l:cur_file, '\\', '/', 'g')
  endif
  let l:command_fmt = g:RG_DEFAULT_CONFIG . " --no-filename -- " . a:str . ' ' .l:cur_file
  let l:preview_script_str = 'bat --color=always --theme=gruvbox-dark ' . l:cur_file . ' --highlight-line {1}'
  let l:fzf_opt = g:FZF_DEFAULT_OPTS + ['--delimiter', ':',
        \ '--preview', l:preview_script_str,
        \ '--preview-window', 'up,70%,border-bottom,hidden,wrap,+{1}+3/3,~3']
  call fzf#run({'source': l:command_fmt,
        \ 'options': l:fzf_opt,
        \ 'window': s:default_windows,
        \ 'sink': function('s:edit_rg_file')})
endfunction

function s:RgcFunction(str)
  execute 'Rg ' . a:str
endfunction

function! s:OpenBufferWithFZFVim()
  " 获取当前打开的所有缓冲区的编号和名称
  let l:bufs = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let l:bufList = join(map(l:bufs, 'v:val . " " . substitute(bufname(v:val), "\\", "/", "g")'), "\n")

  " 调用 fzf#run 来选择缓冲区。注意：需要 fzf.vim 插件。
  call s:fzf_for_rg('echo ' . shellescape(l:bufList), 's:OpenSelectedBuffer', 'bat --color=always --theme=gruvbox-dark {}')
endfunction

function! s:OpenSelectedBuffer(selected_buffer)
  let buffer_number = matchstr(a:selected_buffer, '^\d\+')
  if len(buffer_number) > 0
    exec 'buffer ' . buffer_number
  endif
endfunction

command! -nargs=1 -complete=dir Rfile call s:FindFile(<f-args>, 0)
command! -nargs=? -complete=dir Rfa call s:FindFile(<q-args>, 1)
command! -nargs=0 Rbufferc call s:FindWordInCurBuffer(expand('<cword>'))
command! -nargs=0 Rbuffer call s:FindWordInCurBuffer('.')
command! -nargs=1 Rf call s:RipgrepFzfFunction(<q-args>, 1)
command! -nargs=0 Rfc call s:RipgrepFzfFunction(expand('<cword>'), 0)
command! -nargs=1 Ri call s:RipgrepFzfFunctionRef(<q-args>, 1)
command! -nargs=0 Ric call s:RipgrepFzfFunctionRef(expand('<cword>'), 0)
command! -nargs=1 Rc call s:RipgrepFzfClassDefine(<q-args>, 1)
command! -nargs=0 Rcc call s:RipgrepFzfClassDefine(expand('<cword>'), 0)
command! -nargs=1 Rv call s:RipgrepFzfValDefine(<q-args>, 1)
command! -nargs=0 Rvc call s:RipgrepFzfValDefine(expand('<cword>'), 0)
command! -nargs=* Rgc call s:RgcFunction(expand('<cword>'))
command! -nargs=* Raa call s:RipgrepFzfAll(0, '', <f-args>)
command! -nargs=? Ra call s:RipgrepFzf(<q-args>, '', '--no-ignore-vcs')
command! -nargs=0 Rac call s:RipgrepFzf(expand('<cword>'), '', '--no-ignore')
command! -nargs=0 Raac call s:RipgrepFzf(expand('<cword>'), '', '--no-ignore ')
command! -nargs=? RG call s:RipgrepFzf(<q-args>, 'h,hpp,cpp,cc,c,m,mm,java,ets', '-g !"*unittest*" --no-ignore-vcs')
command! -nargs=0 RGc call s:RipgrepFzf(expand('<cword>'), 'h,hpp,cpp,cc,c,m,mm,java,ets', '-g !"*unittest*" --no-ignore-vcs')
command! -nargs=? Rgn call s:RipgrepFzf(<q-args>, "gn,gni", "--no-ignore-vcs")
command! -nargs=0 Rgnc call s:RipgrepFzf(expand('<cword>'), "gn,gni", "--no-ignore-vcs")
command! -nargs=? Rpy call s:RipgrepFzf(<q-args>, "py", "--no-ignore-vcs")
command! -nargs=0 Rpyc call s:RipgrepFzf(expand('<cword>'), "py", "--no-ignore-vcs")
command! -nargs=? Rja call s:RipgrepFzf(<q-args>, "java", "--no-ignore-vcs")
command! -nargs=0 Rjac call s:RipgrepFzf(expand('<cword>'), "java", "--no-ignore-vcs")
command! -nargs=? Rsh call s:RipgrepFzf(<q-args>, "sh,bash,zsh", "--no-ignore-vcs")
command! -nargs=0 Rshc call s:RipgrepFzf(expand('<cword>'), "sh", "--no-ignore-vcs")

if IsMsys2()
  command! -nargs=0 Buffers call s:OpenBufferWithFZFVim()
endif
