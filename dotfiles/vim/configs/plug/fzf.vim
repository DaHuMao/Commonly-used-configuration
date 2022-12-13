let g:RG_DEFAULT_CONFIG="rg --column --line-number --no-heading --color=always --no-ignore-vcs --max-columns 250 --max-filesize 200K "
"let g:FZF_COLOR=['--color=preview-bg:#223344,border:#778899,header:#ed8796', '--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796', '--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6', '--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796']
let g:FZF_DEFAULT_OPTS=['--ansi', '--layout=reverse', '--info=inline', '--bind', 'ctrl-/:toggle-preview', '--bind', 'ctrl-b:preview-half-page-up,ctrl-n:preview-half-page-down', '--bind', "ctrl-y:execute-silent(ruby -e 'puts ARGV' {+} | pbcopy)+abort", '--preview-window', 'right:50%:hidden']
let s:Spec = {'options': g:FZF_DEFAULT_OPTS }

" Files + devicons
function! Fzf_dev()
  let l:fzf_files_options = '--preview "rougify {2..-1} | head -'.&lines.'"'

  function! s:files()
    let l:files = split(system($FZF_DEFAULT_COMMAND), '\n')
    return s:prepend_icon(l:files)
  endfunction

  function! s:prepend_icon(candidates)
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

function! s:edit_file(file_name)
  execute 'silent e ' . a:file_name
endfunction

function! s:edit_rg_file(strr)
  let s:arr = split(a:strr, ':')
  echom s:arr
  execute 'silent e ' . s:arr[0]
  execute s:arr[1]
  execute 'normal!' . s:arr[2] . 'l'
endfunction

function! Fzf_wrap(source, edit_fun_name, preview_script)
  let s:preview_script_str = '~/.myzsh/bin/rg-edit.zsh {}'
  if a:preview_script != ''
    let s:preview_script_str = a:preview_script
  endif
  echom s:preview_script_str
  call fzf#run({'source': a:source,
        \ 'options': g:FZF_DEFAULT_OPTS + ['--preview', s:preview_script_str],
        \ 'window': {'width': 0.8, 'height': 0.8},
  \ 'sink': function(a:edit_fun_name)})
endfunction

function! RipgrepFzf(query, file_suffix, exclude_cmd)
  let s:str = "--smart-case -e ''"
  if strlen(a:query) > 0
    let s:str = "'" . a:query . "'"
  endif
  let s:command_fmt = g:RG_DEFAULT_CONFIG." -g '*.{%s}' %s %s || true"
  let s:initial_command = printf(s:command_fmt, a:file_suffix, a:exclude_cmd, s:str)
  echom s:initial_command
  call Fzf_wrap(s:initial_command, 's:edit_rg_file', '')
endfunction

function! RipgrepFzfAll(...)
  let s:command_fmt = g:RG_DEFAULT_CONFIG
  if a:0 > 0
    let s:command_fmt .= ' -e ' . a:1
  else
    let s:command_fmt .= " --smart-case -e  ''"
  endif
  if a:0 > 1
    let s:command_fmt .= " -g '*.{" . a:2 . "}'"
  endif
  if a:0 > 2
    let s:command_fmt .= ' ' . a:3
  endif
  let s:command_fmt .= ' || true'
  call Fzf_wrap(s:initial_command, 's:edit_rg_file', '')
endfunction

function! RipgrepFzfFunction(func_name, enable_smart_case)
  let s:smart_case = ''
  if a:enable_smart_case > 0
    let s:smart_case = ' --smart-case '
  endif
  let s:str1='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:func_name . '\('
  let s:str2='^ *' . a:func_name . '\('
  let s:command_fmt = g:RG_DEFAULT_CONFIG . s:smart_case . " -g '*.{h}' -e \"%s|%s\" || true"
  let s:initial_command = printf(s:command_fmt, s:str1, s:str2)
  call Fzf_wrap(s:initial_command, 's:edit_rg_file', '')
endfunction

function! RipgrepFzfClassDefine(class_name, enable_smart_case)
  let s:smart_case = ''
  if a:enable_smart_case > 0
    let s:smart_case = ' --smart-case '
  endif
  let s:str1="#define *" . a:class_name
  let s:str2="using *"  . a:class_name . ' *='
  let s:str3="class *"  . a:class_name . ' '
  let s:str4="struct *"  . a:class_name . ' '
  let s:str5="enum *"  . a:class_name . ' '
  let s:str6="typedef .* " . a:class_name . ' *;'
  let s:gstr1="class *"  . a:class_name . ' *;'
  let s:gstr2="struct *"  . a:class_name . ' *;'
  let s:command_fmt = g:RG_DEFAULT_CONFIG  . s:smart_case . " -g '*.{h}' -e \"%s|%s|%s|%s|%s|%s\" || true | rg -v \"%s|%s\""
  let s:initial_command = printf(s:command_fmt, s:str1, s:str2, s:str3, s:str4, s:str5, s:str6, s:gstr1, s:gstr2)
  call Fzf_wrap(s:initial_command, 's:edit_rg_file', '')
endfunction

function! RipgrepFzfValDefine(val_name, enable_smart_case)
  let s:smart_case = ''
  if a:enable_smart_case > 0
    let s:smart_case = ' --smart-case '
  endif
  let s:str1='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:val_name . ' *;'
  let s:str2='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:val_name . ' *='
  let s:str3='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:val_name . ' .*;'
  let s:command_fmt = g:RG_DEFAULT_CONFIG . s:smart_case . " -g '*.{h,cpp,cc,c,m,mm,java}' -e \"%s|%s|%s\"|| true"
  let s:initial_command = printf(s:command_fmt, s:str1, s:str2, s:str3)
  call Fzf_wrap(s:initial_command, 's:edit_rg_file', '')
endfunction

function! RipgrepFzfFunctionRef(func_name, enable_smart_case)
  let s:smart_case = ''
  if a:enable_smart_case > 0
    let s:smart_case = ' --smart-case '
  endif
  let s:str1=' *[a-zA-Z0-9_]+::' . a:func_name . '\('
  let s:str2='^ *[a-zA-Z0-9_]+  *' . a:func_name . '.*\{'
  let s:command_fmt = g:RG_DEFAULT_CONFIG . s:smart_case . " -g '*.{cpp,cc,c}' -e \"%s|%s\" || true"
  let s:initial_command = printf(s:command_fmt, s:str1, s:str2)
  call Fzf_wrap(s:initial_command, 's:edit_rg_file', '')
endfunction


function FindFile(file_path)
  let s:command_fmt='fd --type f --no-ignore-vcs --hidden --follow --exclude .o --exclude .git . ' . a:file_path
  call Fzf_wrap(s:command_fmt, 's:edit_file', 'bat --color=always --theme=gruvbox-dark {}')
endfunction

function FindWordInCurBuffer(str)
  let s:cur_file=bufname("%")
  let s:command_fmt= g:RG_DEFAULT_CONFIG . " --with-filename -- " . a:str . ' ' .s:cur_file
  call Fzf_wrap(s:command_fmt, 's:edit_rg_file', '')
endfunction

command! -nargs=* Ra call RipgrepFzfAll(<f-args>)
command! -nargs=0 Rac call RipgrepFzfAll(expand('<cword>', <f-args>))
command! -nargs=1 -complete=dir Rfile call FindFile(<f-args>)
command! -nargs=0 Rbufferc call FindWordInCurBuffer(expand('<cword>'))
command! -nargs=0 Rbuffer call FindWordInCurBuffer('.')
command! -nargs=1 Rf call RipgrepFzfFunction(<q-args>, 1)
command! -nargs=0 Rfc call RipgrepFzfFunction(expand('<cword>'), 0)
command! -nargs=1 Ri call RipgrepFzfFunctionRef(<q-args>, 1)
command! -nargs=0 Ric call RipgrepFzfFunctionRef(expand('<cword>'), 0)
command! -nargs=1 Rc call RipgrepFzfClassDefine(<q-args>, 1)
command! -nargs=0 Rcc call RipgrepFzfClassDefine(expand('<cword>'), 0)
command! -nargs=1 Rv call RipgrepFzfValDefine(<q-args>, 1)
command! -nargs=0 Rvc call RipgrepFzfValDefine(expand('<cword>'), 0)
command! -nargs=? RG call RipgrepFzf(<q-args>, "h,hpp,cpp,cc,c,m,mm,java", "-g !'*unittest*'")
command! -nargs=0 RGCword call RipgrepFzf(expand('<cword>'), "h,hpp,cpp,cc,c,m,mm,java", "-g !'*unittest*'")
command! -nargs=? Rgn call RipgrepFzf(<q-args>, "gn,gni", "")
command! -nargs=0 Rgnc call RipgrepFzf(expand('<cword>'), "gn,gni", "")
command! -nargs=? Rpy call RipgrepFzf(<q-args>, "py", "")
command! -nargs=0 Rpyc call RipgrepFzf(expand('<cword>'), "py", "")
command! -nargs=? Rja call RipgrepFzf(<q-args>, "java", "")
command! -nargs=0 Rjac call RipgrepFzf(expand('<cword>'), "java", "")
command! -nargs=? Rsh call RipgrepFzf(<q-args>, "sh,bash,zsh", "")
command! -nargs=0 Rshc call RipgrepFzf(expand('<cword>'), "sh", "")
