
. myposh/tool.ps1
if (-not (test-administrator)) {
    log_error "Please run this script as an administrator."
    exit
}

# Check if PowerShell 7+ is already installed
$pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
if ($pwshCmd) {
    $pwshPath = $pwshCmd.Source
} else {
    # 尝试使用默认安装路径
    $pwshPath = Join-Path $Env:ProgramFiles 'PowerShell\\7\\pwsh.exe'
}

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
    # 安装后重新检测 pwsh 路径
    $pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwshCmd) {
        $pwshPath = $pwshCmd.Source
    } elseif (Test-Path (Join-Path $Env:ProgramFiles 'PowerShell\\7\\pwsh.exe')) {
        $pwshPath = Join-Path $Env:ProgramFiles 'PowerShell\\7\\pwsh.exe'
    } else {
        log_error "PowerShell 7 安装完成但无法找到 pwsh，可手动检查 PATH 或安装位置。"
        exit 1
    }
}
./setup_font.ps1
Start-Process $pwshPath -ArgumentList ./config.ps1 -Wait
