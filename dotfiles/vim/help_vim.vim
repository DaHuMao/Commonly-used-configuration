
command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#Complete G   exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>)
command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#Complete Git exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>)

if exists(':Gstatus') !=# 2
  exe 'command! -bang -bar     -range=-1' s:addr_other 'Gstatus exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>)'
endif

for s:cmd in ['Commit', 'Revert', 'Merge', 'Rebase', 'Pull', 'Push', 'Fetch', 'Blame']
  if exists(':G' . tolower(s:cmd)) != 2
    exe 'command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#' . s:cmd . 'Complete G' . tolower(s:cmd) 'exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", "' . tolower(s:cmd) . ' " . <q-args>)'
  endif
endfor
unlet s:cmd

exe "command! -bar -bang -nargs=? -complete=customlist,fugitive#CdComplete Gcd  exe fugitive#Cd(<q-args>, 0)"
exe "command! -bar -bang -nargs=? -complete=customlist,fugitive#CdComplete Glcd exe fugitive#Cd(<q-args>, 1)"

exe 'command! -bang -nargs=? -range=-1' s:addr_wins '-complete=customlist,fugitive#GrepComplete Ggrep  exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", "grep -O " . <q-args>)'
exe 'command! -bang -nargs=? -range=-1' s:addr_wins '-complete=customlist,fugitive#GrepComplete Gcgrep exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", "grep -O " . <q-args>)'
exe 'command! -bang -nargs=? -range=-1' s:addr_wins '-complete=customlist,fugitive#GrepComplete Glgrep exe fugitive#Command(0, <count> > 0 ? <count> : 0, +"<range>", <bang>0, "<mods>", "grep -O " . <q-args>)'

exe 'command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#LogComplete Glog  :exe fugitive#LogCommand(<line1>,<count>,+"<range>",<bang>0,"<mods>",<q-args>, "")'
exe 'command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#LogComplete Gclog :exe fugitive#LogCommand(<line1>,<count>,+"<range>",<bang>0,"<mods>",<q-args>, "c")'
exe 'command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#LogComplete GcLog :exe fugitive#LogCommand(<line1>,<count>,+"<range>",<bang>0,"<mods>",<q-args>, "c")'
exe 'command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#LogComplete Gllog :exe fugitive#LogCommand(<line1>,<count>,+"<range>",<bang>0,"<mods>",<q-args>, "l")'
exe 'command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#LogComplete GlLog :exe fugitive#LogCommand(<line1>,<count>,+"<range>",<bang>0,"<mods>",<q-args>, "l")'

exe 'command! -bar -bang -nargs=*                          -complete=customlist,fugitive#EditComplete   Ge       exe fugitive#Open("edit<bang>", 0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=*                          -complete=customlist,fugitive#EditComplete   Gedit    exe fugitive#Open("edit<bang>", 0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=*                          -complete=customlist,fugitive#ReadComplete   Gpedit   exe fugitive#Open("pedit", <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=* -range=-1' s:addr_other '-complete=customlist,fugitive#ReadComplete   Gsplit   exe fugitive#Open((<count> > 0 ? <count> : "").(<count> ? "split" : "edit"), <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=* -range=-1' s:addr_other '-complete=customlist,fugitive#ReadComplete   Gvsplit  exe fugitive#Open((<count> > 0 ? <count> : "").(<count> ? "vsplit" : "edit!"), <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=* -range=-1' s:addr_tabs  '-complete=customlist,fugitive#ReadComplete   Gtabedit exe fugitive#Open((<count> >= 0 ? <count> : "")."tabedit", <bang>0, "<mods>", <q-args>, [<f-args>])'

if exists(':Gr') != 2
  exe 'command! -bar -bang -nargs=* -range=-1                -complete=customlist,fugitive#ReadComplete   Gr     exe fugitive#ReadCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
endif
exe 'command! -bar -bang -nargs=* -range=-1                -complete=customlist,fugitive#ReadComplete   Gread    exe fugitive#ReadCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'

exe 'command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Gdiffsplit  exe fugitive#Diffsplit(1, <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Ghdiffsplit exe fugitive#Diffsplit(0, <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Gvdiffsplit exe fugitive#Diffsplit(0, <bang>0, "vert <mods>", <q-args>, [<f-args>])'

exe 'command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Gw     exe fugitive#WriteCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Gwrite exe fugitive#WriteCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Gwq    exe fugitive#WqCommand(   <line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'

exe 'command! -bar -bang -nargs=1 -complete=customlist,fugitive#CompleteObject GRemove exe fugitive#RemoveCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=1 -complete=customlist,fugitive#CompleteObject GDelete exe fugitive#DeleteCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=1 -complete=customlist,fugitive#CompleteObject GMove   exe fugitive#MoveCommand(  <line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
exe 'command! -bar -bang -nargs=1 -complete=customlist,fugitive#RenameComplete GRename exe fugitive#RenameCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
if exists(':Gremove') != 2
  exe 'command! -bar -bang -nargs=1 -complete=customlist,fugitive#CompleteObject Gremove exe fugitive#RemoveCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
endif
if exists(':Gdelete') != 2
  exe 'command! -bar -bang -nargs=1 -complete=customlist,fugitive#CompleteObject Gdelete exe fugitive#DeleteCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
endif
if exists(':Gmove') != 2
  exe 'command! -bar -bang -nargs=1 -complete=customlist,fugitive#CompleteObject Gmove   exe fugitive#MoveCommand(  <line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
endif
if exists(':Grename') != 2
  exe 'command! -bar -bang -nargs=1 -complete=customlist,fugitive#RenameComplete Grename exe fugitive#RenameCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
endif

exe 'command! -bar -bang -range=-1 -nargs=* -complete=customlist,fugitive#CompleteObject GBrowse exe fugitive#BrowseCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
if exists(':Gbrowse') != 2
  exe 'command! -bar -bang -range=-1 -nargs=* -complete=customlist,fugitive#CompleteObject Gbrowse exe fugitive#BrowseCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])'
endif

# ~/.fzf/plugin/fzf.vim :s:callback :947 
if get(a:dict, 'name') == 'fd'
  let a:lines[1]=a:lines[1].':1:1:'
  echo a:lines[1]
endif


