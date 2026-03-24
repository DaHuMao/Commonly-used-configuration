Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

Set-PSReadLineKeyHandler -Chord Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function ForwardDeleteInput
Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock { find_history }
Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock { fzf_common_selected }
Set-PSReadLineKeyHandler -Chord Ctrl+UpArrow -ScriptBlock { find_pre_nonsapce }
Set-PSReadLineKeyHandler -Chord Ctrl+DownArrow -ScriptBlock { find_next_nonsapce }

