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

let g:rg_command = '
  \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "*.{h,hpp,js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf}"
  \ -g "!{.git,node_modules,vendor,xcode*}/*" '

command! -bang -nargs=* Rgf call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)

function! CustomGrep(file_reg, reg_arr)
  let l:command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -g '.'"'.a:file_reg.'"'
  let l:pattern_reg = expand("<cword>")
  if len(a:reg_arr) > 0
    let l:reg_str_loc = join(a:reg_arr, '|')
    let l:reg_arr_loc = split(l:reg_str_loc, '%')
    let l:pattern_reg = join(l:reg_arr_loc, l:pattern_reg) 
  endif
  let l:command_fmt = l:command_fmt.' -e '.'"'.l:pattern_reg.'"'
  "let command_fmt = 'rg -g '.a:file_reg.' -e '.'"'.l:pattern_reg.'"'
  echo l:command_fmt
  call fzf#vim#grep(l:command_fmt, 1, fzf#vim#with_preview(), 0)
endfunction  

function! CustomGrepCurrentFile(is_current_word)
  let l:command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case '.expand('%')
  if a:is_current_word
    let l:command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -e '.expand("<cword>")." ".expand('%')
  endif
  echo l:command_fmt
  call fzf#vim#grep(l:command_fmt, 1, fzf#vim#with_preview(), 0)
endfunction

function! Mytest()
  let s:filename=expand('<cfile>')
  let s:afile=expand('<afile>')
  let s:abuf=expand('<abuf>')
  let s:amatch=expand('<amatch>')
      echo '1'.s:filename
      echo '2'.s:afile
      echo '3'.s:abuf
      echo '4'.s:amatch
      echo '5'.expand('<sfile>:p')
      echo '6'.expand('%')
endfunction
   
  
