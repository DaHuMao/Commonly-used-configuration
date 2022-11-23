"let $FZF_DEFAULT_COMMAND = 'ag --hidden -l -g ""'
" ripgrep
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden  --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" --ignore-file tags'.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
endif

let g:RG_DEFAULT_CONFIG="rg --column --line-number --no-heading --color=always --no-ignore-vcs --smart-case  --max-columns 250 --max-filesize 200K "
let g:FZF_DEFAULT_OPTS=['--layout=reverse', '--info=inline', '--preview', 'bat --color=always --theme=TwoDark {}', '--bind', 'ctrl-/:toggle-preview']

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


function! RipgrepFzf(query, file_suffix, exclude_cmd)
  let s:str = "''"
  if strlen(a:query) > 0
    let s:str = a:query
  endif
  let s:command_fmt = g:RG_DEFAULT_CONFIG."-g '*.{%s}' %s -e %s || true"
  let s:initial_command = printf(s:command_fmt, a:file_suffix, a:exclude_cmd, s:str)
  echom s:initial_command
  call fzf#vim#grep(s:initial_command, 1, fzf#vim#with_preview(), 0)
endfunction

function! RipgrepFzfAll(...)
  let s:command_fmt = g:RG_DEFAULT_CONFIG
  if a:0 > 0
    let s:command_fmt .= ' -e ' . a:1
  else
    let s:command_fmt .= " -e  ''"
  endif
  if a:0 > 1
    let s:command_fmt .= " -g '*.{" . a:2 . "}'"
  endif
  if a:0 > 2
    let s:command_fmt .= ' ' . a:3
  endif
  let s:command_fmt .= ' || true'
  echom s:command_fmt
  call fzf#vim#grep(s:command_fmt, 1, fzf#vim#with_preview(), 0)
endfunction

function! RipgrepFzfFunction(func_name)
  let s:str1='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:func_name . '\('
  let s:str2='^ *' . a:func_name . '\('
  let s:command_fmt = g:RG_DEFAULT_CONFIG . " -g '*.{h}' -e \"%s|%s\" || true"
  let s:initial_command = printf(s:command_fmt, s:str1, s:str2)
  echom s:initial_command
  call fzf#vim#grep(s:initial_command, 1, fzf#vim#with_preview(), 0)
endfunction

function! RipgrepFzfClassDefine(class_name)
  let s:str1="#define *" . a:class_name
  let s:str2="using *"  . a:class_name
  let s:str3="class *"  . a:class_name
  let s:str4="struct *"  . a:class_name
  let s:gstr1="'class *"  . a:class_name . ' *;'
  let s:gstr2="'struct *"  . a:class_name . ' *;'
  let s:command_fmt = g:RG_DEFAULT_CONFIG . " -g '*.{h}' -e \"%s|%s|%s|%s\" || true | rg -v \"%s|%s\""
  let s:initial_command = printf(s:command_fmt, s:str1, s:str2, s:str3, s:str4, s:gstr1, s:gstr2)
  echom s:initial_command
  call fzf#vim#grep(s:initial_command, 1, fzf#vim#with_preview(), 0)
endfunction

function! RipgrepFzfValDefine(val_name)
  let s:str1='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:val_name . ' *;'
  let s:str2='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:val_name . ' *='
  let s:str3='^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\*?  *' . a:val_name . ' .*;'
  let s:command_fmt = g:RG_DEFAULT_CONFIG . " -g '*.{h,cpp,cc,c,m,mm,java}' -e \"%s|%s|%s\"|| true"
  let s:initial_command = printf(s:command_fmt, s:str1, s:str2, s:str3)
  echom s:initial_command
  call fzf#vim#grep(s:initial_command, 1, fzf#vim#with_preview(), 0)
endfunction

function Fzf_wrap(source, str_type)
  function! s:edit_file(eledict)
    echom a:eledict
    execute 'silent e ' . a:eledict
    "if g_str_type ==! 'file'
    "elseif a:str_type ==! 'str'
    "  let g_cur_file = bufname('%')
    "endif
  endfunction
  call fzf#run({'source': a:source,
  \ 'options': g:FZF_DEFAULT_OPTS,
  \ 'window': {'width': 0.8, 'height': 0.8},
  \ 'sink': function('s:edit_file')})
endfunction

function FindFile(file_path)
  let s:command_fmt='fd --type f --no-ignore-vcs --hidden --follow --exclude .o --exclude .git . ' . a:file_path
  echom s:command_fmt
  call Fzf_wrap(s:command_fmt, 'file')
endfunction

function FindWordInCurBuffer(str)
  let s:cur_file=bufname("%")
  let s:command_fmt= g:RG_DEFAULT_CONFIG . " --with-filename -- " . a:str . ' ' .s:cur_file
  echom s:command_fmt
  call fzf#vim#grep(s:command_fmt, 1, fzf#vim#with_preview(), 0)
endfunction

command! -nargs=* Ra call RipgrepFzfAll(<f-args>)
command! -nargs=0 Rac call RipgrepFzfAll(expand('<cword>', <f-args>))
command! -nargs=1 -complete=dir Rfile call FindFile(<f-args>)
command! -nargs=0 Rbufferc call FindWordInCurBuffer(expand('<cword>'))
command! -nargs=0 Rbuffer call FindWordInCurBuffer('.')
command! -nargs=1 Rf call RipgrepFzfFunction(<q-args>)
command! -nargs=0 Rfc call RipgrepFzfFunction(expand('<cword>'))
command! -nargs=1 Rc call RipgrepFzfClassDefine(<q-args>)
command! -nargs=0 Rcc call RipgrepFzfClassDefine(expand('<cword>'))
command! -nargs=1 Rv call RipgrepFzfValDefine(<q-args>)
command! -nargs=0 Rvc call RipgrepFzfValDefine(expand('<cword>'))
command! -nargs=? RG call RipgrepFzf(<q-args>, "h,cpp,cc,c,m,mm,java", "-g !'*unittest*'")
command! -nargs=0 RGCword call RipgrepFzf(expand('<cword>'), "h,cpp,cc,c,m,mm,java", "-g !'*unittest*'")
command! -nargs=? Rgn call RipgrepFzf(<q-args>, "gn,gni", "")
command! -nargs=0 Rgnc call RipgrepFzf(expand('<cword>'), "gn,gni", "")
command! -nargs=? Rpy call RipgrepFzf(<q-args>, "py", "")
command! -nargs=0 Rpyc call RipgrepFzf(expand('<cword>'), "py", "")
command! -nargs=? Rja call RipgrepFzf(<q-args>, "java", "")
command! -nargs=0 Rjac call RipgrepFzf(expand('<cword>'), "java", "")
command! -nargs=? Rsh call RipgrepFzf(<q-args>, "sh,bash,zsh", "")
command! -nargs=0 Rshc call RipgrepFzf(expand('<cword>'), "sh", "")



