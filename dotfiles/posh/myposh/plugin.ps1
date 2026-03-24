# 自动加载 oh-my-posh 并设置主题
$themePath = $env:POSH_THEMES_PATH
if (-not [string]::IsNullOrWhiteSpace($themePath) -and (Test-Path $themePath)) {
log_info "Checking for theme file at: $env:POSH_THEMES_PATH\avit.omp.json"
  if (Test-Path "$env:POSH_THEMES_PATH\avit.omp.json") {
    try {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\avit.omp.json" | Invoke-Expression
        log_info "oh-my-posh loaded successfully"
    } catch {
        log_info "Error initializing oh-my-posh: $_"
    }
  } else {
    log_error "Theme file not found: $env:POSH_THEMES_PATH\avit.omp.json"
  }
} else {
  log_error "POSH_THEMES_PATH is invalid: $themePath"
}

# Import PSReadLine and set options
try {
    Import-Module PSReadLine
    log_info "PSReadLine module imported successfully"
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -HistorySavePath "$env:USERPROFILE\Documents\PowerShell\PSReadLine_History.txt"
    log_info "PSReadLine configured successfully"
} catch {
    log_error "Error configuring PSReadLine: $_"
}

try {
    Import-Module posh-git
} catch {
    log_error "Error configuring posh-git"
}







