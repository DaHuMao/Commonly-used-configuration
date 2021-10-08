
"config
"=============================
"leaderf
let g:Lf_UseVersionControlTool = 0
let g:Lf_WildIgnore = { 
            \ 'dir': ['img','.svn','.git','.hg','.vscode', '.xcodeproject'],
            \ 'file': ['run.*','*.png','*.sw?','~$*','*.bak','*.exe','*.o','*.ko','*.so','*.py[co]']
            \}
" popup mode
"let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
let g:Lf_PreviewResult = {'Function': 1, 'BufTag': 1, 'File': 1 }
"==============================

