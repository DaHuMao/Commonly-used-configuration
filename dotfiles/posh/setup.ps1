
. myposh/tool.ps1
if (-not (test-administrator)) {
    log_error "Please run this script as an administrator."
    exit
}

# Check if PowerShell 7+ is already installed
$pwshPath = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
$needInstall = $false

if (Test-Path $pwshPath) {
    try {
        $pwshVersion = & $pwshPath -NoProfile -Command '$PSVersionTable.PSVersion.Major'
        if ($pwshVersion -ge 7) {
            log_info "PowerShell $pwshVersion is already installed at $pwshPath"
        } else {
            log_warn "PowerShell version is $pwshVersion, upgrading to 7+"
            $needInstall = $true
        }
    } catch {
        log_warn "Could not detect PowerShell version, will install"
        $needInstall = $true
    }
} else {
    log_info "PowerShell 7+ not found, installing..."
    $needInstall = $true
}

if ($needInstall) {
    install_or_update winget
    winget install --id Microsoft.Powershell --source winget --force
}

Start-Process $pwshPath -ArgumentList ./config.ps1 -Wait
