# Install Nerd Font for Oh My Posh
# This script provides reusable functions for font installation

# Load font configuration
. ./font_config.ps1
$fontConfig = Get-FontConfig

# Function to check if Nerd Font is installed
function Test-NerdFont {
    param(
        [hashtable]$Config = $script:fontConfig
    )

    $fontsFolder = [System.Environment]::GetFolderPath('Fonts')
    $userFontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

    $systemFontPath = "$fontsFolder\$($Config.FilePattern)"
    $userFontPath = "$userFontsFolder\$($Config.FilePattern)"

    if (Test-Path $systemFontPath) {
        return @{ Installed = $true; Path = $systemFontPath; Scope = "System" }
    } elseif (Test-Path $userFontPath) {
        return @{ Installed = $true; Path = $userFontPath; Scope = "User" }
    } else {
        return @{ Installed = $false; Path = $null; Scope = $null }
    }
}

# Function to install Nerd Font
function Install-NerdFont {
    param(
        [switch]$Silent,
        [hashtable]$Config = $script:fontConfig
    )

    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        if (-not $Silent) {
            log_error "oh-my-posh is not installed. Please install it first."
        }
        return $false
    }

    try {
        if (-not $Silent) {
            log_info "Installing Nerd Font ($($Config.DisplayName))..."
        }
        Invoke-Expression (Get-FontInstallCommand)
        if (-not $Silent) {
            log_info "Nerd Font ($($Config.DisplayName)) installed successfully."
            log_warn "Please configure your terminal to use '$($Config.DisplayName)' font."
            log_warn "Terminal settings -> Appearance -> Font face -> $($Config.DisplayName)"
        }
        return $true
    } catch {
        if (-not $Silent) {
            log_error "Failed to install Nerd Font: $_"
            log_warn "You can manually install it by running: $(Get-FontInstallCommand)"
        }
        return $false
    }
}

# Main script logic (only runs when script is executed directly)
if ($MyInvocation.InvocationName -ne '.') {
    . myposh/tool.ps1

    log_info "=== Oh My Posh Nerd Font Installer ==="
    log_info ""

    # Check if oh-my-posh is installed
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        log_error "oh-my-posh is not installed. Please install it first."
        log_info "Run: winget install JanDeDobbeleer.OhMyPosh -s winget"
        exit 1
    }

    $fontStatus = Test-NerdFont

    log_info "Checking for Nerd Font installation..."

    if ($fontStatus.Installed) {
        log_info "✓ Nerd Font is installed ($($fontStatus.Scope)): $($fontStatus.Path)"
        log_info ""
        log_info "Font Status: ✓ INSTALLED"
        log_info "Font Name: $($fontConfig.DisplayName)"
        log_info ""
        log_info "To use this font in your terminal:"
        log_info "  1. Open Windows Terminal settings (Ctrl+,)"
        log_info "  2. Go to: Defaults or specific profile (e.g., PowerShell)"
        log_info "  3. Click on 'Appearance' tab"
        log_info "  4. Under 'Font face', select: $($fontConfig.DisplayName)"
        log_info "  5. Save and restart terminal"
        log_info ""

        # Ask if user wants to reinstall
        $choice = Read-Host "Do you want to reinstall the font? (y/N)"
        if ($choice -ne "y" -and $choice -ne "Y") {
            log_info "Skipping font installation."
            exit 0
        }
    } else {
        log_warn "✗ Nerd Font ($($fontConfig.DisplayName)) is not installed."
    }

    # Install the font
    log_info ""
    if (Install-NerdFont) {
        log_info ""
        log_info "✓ Nerd Font installed successfully!"
        log_info ""
        log_warn "IMPORTANT: Configure your terminal to use the font:"
        log_warn ""
        log_warn "  Windows Terminal:"
        log_warn "    1. Open Settings (Ctrl+,)"
        log_warn "    2. Select your PowerShell profile"
        log_warn "    3. Go to 'Appearance' tab"
        log_warn "    4. Set 'Font face' to: $fontName"
        log_warn "    5. Save and restart terminal"
        log_warn ""
        log_warn "  VS Code:"
        log_warn "    1. Open Settings (Ctrl+,)"
        log_warn "    2. Search for 'terminal.integrated.fontFamily'"
        log_warn "    3. Set value to: $($fontConfig.DisplayName)"
        log_warn ""
    } else {
        log_error ""
        log_error "You can try manually:"
        log_error "  1. Run: oh-my-posh font install"
        log_error "  2. Select 'meslo' from the list"
        log_error "  3. Or download from: https://www.nerdfonts.com/font-downloads"
        exit 1
    }
}
