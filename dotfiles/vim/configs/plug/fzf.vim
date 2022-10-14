"let $FZF_DEFAULT_COMMAND = 'ag --hidden -l -g ""'
" ripgrep
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden  --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" --ignore-file tags'.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
endif

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



function! RipgrepFzf(query, fullscreen, file_suffix)
    let command_fmt = "rg --column --line-number --no-heading --color=always --no-ignore --smart-case -g '*.{%s}' -e %s || true"
    let initial_command = printf(command_fmt, a:file_suffix, shellescape(a:query))
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(), a:fullscreen)
endfunction

function! RipgrepFzfCword(fullscreen, file_suffix)
  let str=expand(expand("<cword>"))
  let command_fmt = "rg --column --line-number --no-heading --color=always --no-ignore --smart-case -g '*.{%s}' -e %s || true"
  let initial_command = printf(command_fmt, a:file_suffix, str)
  echo initial_command
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(), a:fullscreen)
endfunction

function! RipgrepFzfCwordAll(fullscreen)
  let str=expand(expand("<cword>"))
  let command_fmt = "rg --column --line-number --no-heading --color=always --no-ignore --smart-case -e \'%s\' || true"
  let initial_command = printf(command_fmt, str)
  echo initial_command
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(), a:fullscreen)
endfunction

function! RipgrepFzfFunction(fullscreen)
  let str1="'::"  . expand(expand("<cword>")) . '\(' . "'"
  let str2="'" . '\w *' . expand(expand("<cword>")) . '\(.*\).*;' . "'"
  let str3="'" . '\w *' . expand(expand("<cword>")) . '\(.*\) *\{' . "'"
  let str4="'" . '\w *' . expand(expand("<cword>")) . '\(' . "'"
  let command_fmt = "rg --column --line-number --no-heading --color=always --no-ignore --smart-case -g '*.{h,cpp,cc,c,m,mm,java}' -e %s -e %s -e %s -e %s || true"
  let initial_command = printf(command_fmt, str1, str2, str3, str4)
  echo initial_command
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(), a:fullscreen)
endfunction

function! RipgrepFzfClassDefine(fullscreen)
  let str1="'#define *" . expand(expand("<cword>")) . "'"
  let str2="'class *"  . expand(expand("<cword>")) . ' *\{' . "'"
  let str3="'class "  . expand(expand("<cword>"))  . ' *:' . "'"
  let str4="'struct *"  . expand(expand("<cword>")) . ' *\{' . "'"
  let str5="'struct *"  . expand(expand("<cword>")) . ' *:' . "'"
  let str5="'using *"  . expand(expand("<cword>")) .  "'"
  let command_fmt = "rg --column --line-number --no-heading --color=always --no-ignore --smart-case -g '*.{h,cpp,cc,c,m,mm,java}' -e %s -e %s -e %s -e %s -e %s || true"
  let initial_command = printf(command_fmt, str1, str2, str3, str4, str5)
  echo initial_command
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(), a:fullscreen)
endfunction

function! RipgrepFzfValDefine(fullscreen)
  let str1="'" . '\w *' . expand(expand("<cword>")) . '.*;' . "'"
  let str2="'" . '\w *' . expand(expand("<cword>")) . ' *=' . "'"
  let command_fmt = "rg --column --line-number --no-heading --color=always --no-ignore --smart-case -g '*.{h,cpp,cc,c,m,mm,java}' -e %s -e %s || true"
  let initial_command = printf(command_fmt, str1, str2)
  echo initial_command
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(), a:fullscreen)
endfunction

function BufferLinesCwords(fullscreen)
  let str=expand(expand("<cword>"))
  call fzf#vim#lines(str, a:fullscreen)
endfunction

command! -bang -nargs=* Ra
  \ call fzf#vim#grep(
  \   'rg --column --no-ignore --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* -bang Rac
  \ call fzf#vim#grep(
  \   'rg --column --no-ignore --line-number --no-heading --color=always --smart-case -- '.expand(expand("<cword>")), 1,
  \   fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* RFiles
  \ call fzf#vim#grep(
  \   'fd --type f --no-ignore --hidden --follow --exclude .git'.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

command! -nargs=* -bang RLines call BufferLinesCwords(<bang>0)
command! -nargs=* -bang Rff call RipgrepFzfFunction(<bang>0)
command! -nargs=* -bang Rfc call RipgrepFzfClassDefine(<bang>0)
command! -nargs=* -bang Rfv call RipgrepFzfValDefine(<bang>0)
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0, "h,cpp,cc,c,m,mm,java")
command! -nargs=* -bang RGCword call RipgrepFzfCword(<bang>0, "h,cpp,cc,c,m,mm,java")
command! -nargs=* -bang Rgn call RipgrepFzf(<q-args>, <bang>0, "gn")
command! -nargs=* -bang Rpy call RipgrepFzf(<q-args>, <bang>0, "py")
command! -nargs=* -bang Rja call RipgrepFzf(<q-args>, <bang>0, "java")
command! -nargs=* -bang Rsh call RipgrepFzf(<q-args>, <bang>0, "sh")


"============================================ TEST ===========================================================
function! RipgrepFzfInCurrentBuffer(query, fullscreen)
    echom expand(expand("<cword>"))
    let command_fmt = "rg --current-buffer -e %s || true"
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

function! RipgrepFzfExample(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RTT call RipgrepFzfExample(<q-args>, <bang>0)

command! -nargs=* -bang Rl call RipgrepFzfInCurrentBuffer(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir RFF
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}']}, <bang>0)
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)
"============================================ TEST ===========================================================



