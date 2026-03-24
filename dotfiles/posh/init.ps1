$startTimeAll = Get-Date
[Console]::OutputEncoding = [Text.Encoding]::UTF8
. ~/.myposh/posh_config/tool.ps1
. ~/.myposh/posh_config/internal_tool.ps1

log_info "Loading profile... Path: $PROFILE"
log_info "POSH_THEMES_PATH: $env:POSH_THEMES_PATH"
$startTime = Get-Date
. ~/.myposh/posh_config/to_bash_cmd.ps1
log_info "Load ${HOME}/.myposh/posh_config/to_bash_cmd.ps1: $(time_diff $startTime) seconds"

$startTime = Get-Date
. ~/.myposh/env_config.ps1
log_info "Load ${HOME}/.myposh/env.ps1: $(time_diff $startTime) seconds"

$startTime = Get-Date
. ~/.myposh/posh_config/plugin.ps1
log_info "Load ${HOME}/.myposh/posh_config/plugin.ps1: $(time_diff $startTime) seconds"

$startTime = Get-Date
. ~/.myposh/posh_config/fzf_plugin.ps1
log_info "Load ${HOME}/.myposh/posh_config/fzf_plugin.ps1: $(time_diff $startTime) seconds"

$startTime = Get-Date
. ~/.myposh/posh_config/keybinding.ps1
log_info "Load ${HOME}/.myposh/posh_config/keybinding.ps1: $(time_diff $startTime) seconds"

log_info "Load profile: $(time_diff $startTimeAll) seconds"
