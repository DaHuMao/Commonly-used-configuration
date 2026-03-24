. myposh/tool.ps1

# 检查管理员权限，无权限则退出
if (-not (test-administrator)) {
    Write-Error "Please run this script as an administrator."
    exit
}
install_or_update ripgrep rg
install_or_update fd
install_or_update bat
install_or_update fzf
install_or_update perl
install_or_update diff-so-fancy

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

if (Get-InstalledModule -Name PowerShellGet) {
  log_info "PowerShellGet module is available."
} else {
  log_warn "PowerShellGet module is not available. Installing PowerShellGet module."
  Install-Module -Name PowerShellGet -Force -SkipPublisherCheck
  Update-Module -Name PowerShellGet
}

if (Get-InstalledModule -Name oh-my-posh) {
  log_info "oh-my-posh module is available."
} else {
  log_warn "oh-my-posh module is not available. Installing oh-my-posh module."
  Install-Module -Name oh-my-posh -Scope CurrentUser -Force -SkipPublisherCheck
  winget install JanDeDobbeleer.OhMyPosh -s winget
  #Install-Module -Name Terminal-Icons -Repository PSGallery
}

# Install Nerd Font for oh-my-posh icons
# Source font installation functions
. ./install_font.ps1
$fontConfig = Get-FontConfig

log_info "Checking $($fontConfig.DisplayName) installation..."

$fontStatus = Test-NerdFont -Config $fontConfig
if ($fontStatus.Installed) {
    log_info "$($fontConfig.DisplayName) is already installed ($($fontStatus.Scope)): $($fontStatus.Path)"
} else {
    log_warn "$($fontConfig.DisplayName) not found. Installing..."
    $installed = Install-NerdFont -Silent -Config $fontConfig
    if (-not $installed) {
        log_warn "You can manually install it by running: $(Get-FontInstallCommand)"
    }
}

# Configure Windows Terminal to use Nerd Font
log_info "Configuring Windows Terminal font..."
if (Test-Path ./configure_terminal_font.ps1) {
    try {
        & ./configure_terminal_font.ps1
        log_info "Windows Terminal font configuration completed"
    } catch {
        log_warn "Failed to configure Windows Terminal font: $_"
        log_warn "You can manually run: .\configure_terminal_font.ps1"
    }
} else {
    log_warn "configure_terminal_font.ps1 not found, skipping Windows Terminal configuration"
}

if (Get-InstalledModule -Name posh-git) {
  log_info "posh-git module is available."
} else {
  log_warn "posh-git module is not available. Installing posh-git module."
  Install-Module -Name posh-git -Scope CurrentUser -Force -SkipPublisherCheck
}

if (Get-InstalledModule -Name PSReadLine -ErrorAction SilentlyContinue) {
  log_info "PSReadLine module is available."
} else {
  log_warn "PSReadLine module is not available. Installing PSReadLine module."
  try {
    Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
  } catch {
    log_warn "Failed to install with -AllowPrerelease, trying without it"
    Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
  }
}

if (!(Test-Path -Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}
