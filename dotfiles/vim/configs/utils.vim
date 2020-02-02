"open plug github repo in browser by press enter
function! s:go_github()
    let s:repo = matchstr(expand("<cWORD>"), '\v[0-9A-Za-z\-\.]+/[0-9A-Za-z\-\.]+')
    if empty(s:repo)
        echo "GoGithub: No repository found."
    else
        let s:url = 'https://github.com/' . s:repo
        call netrw#BrowseX(s:url, 0)
    end
endfunction

autocmd FileType *vim,*zsh,*bash,*tmux nnoremap <buffer> <silent> <cr> :call <sid>go_github()<cr>
