# Configure Windows Terminal to use Nerd Font
# This script automatically updates Windows Terminal settings

. myposh/tool.ps1

# Load font configuration
. ./font_config.ps1
$fontConfig = Get-FontConfig

log_info "=== Windows Terminal Font Configuration ==="
Write-Host ""

# Check if font is installed
. ./install_font.ps1
$fontStatus = Test-NerdFont -Config $fontConfig

if (-not $fontStatus.Installed) {
    log_error "Nerd Font is not installed. Please run install_font.ps1 first."
    exit 1
}

log_info "Nerd Font is installed at: $($fontStatus.Path)"
Write-Host ""

# Locate Windows Terminal settings dynamically
$wtSettingsPaths = @()

# Try to find Windows Terminal package directories
$packagesPath = "$env:LOCALAPPDATA\Packages"

# Search for both stable and preview versions
$searchPatterns = @(
    "Microsoft.WindowsTerminal_*",
    "Microsoft.WindowsTerminalPreview_*"
)

foreach ($pattern in $searchPatterns) {
    $packages = Get-ChildItem -Path $packagesPath -Directory -Filter $pattern -ErrorAction SilentlyContinue
    foreach ($pkg in $packages) {
        $settingsPath = Join-Path $pkg.FullName "LocalState\settings.json"
        if (Test-Path $settingsPath) {
            $wtSettingsPaths += @{
                Path = $settingsPath
                PackageName = $pkg.Name
                IsPreview = $pkg.Name -like "*Preview*"
            }
        }
    }
}

if ($wtSettingsPaths.Count -eq 0) {
    log_error "Windows Terminal settings file not found."
    log_error "Searched in: $packagesPath\Microsoft.WindowsTerminal*\LocalState\settings.json"
    Write-Host ""
    log_error "Please ensure Windows Terminal is installed."
    log_error "Install from: https://aka.ms/terminal"
    exit 1
}

# If multiple installations found, let user choose or configure all
if ($wtSettingsPaths.Count -gt 1) {
    log_info "Found $($wtSettingsPaths.Count) Windows Terminal installations:"
    for ($i = 0; $i -lt $wtSettingsPaths.Count; $i++) {
        $entry = $wtSettingsPaths[$i]
        $label = if ($entry.IsPreview) { "(Preview)" } else { "(Stable)" }
        log_info "  [$($i+1)] $($entry.PackageName) $label"
    }
    Write-Host ""
    log_info "Configuring all installations..."
    Write-Host ""
} else {
    log_info "Found Windows Terminal: $($wtSettingsPaths[0].PackageName)"
}

# Configure font settings
log_info "Configuring font..."
log_info "  Font: $($fontConfig.DisplayName)"
log_info "  Size: $($fontConfig.Size)"
Write-Host ""

# Process each Windows Terminal installation
$successCount = 0
$failCount = 0

foreach ($wtEntry in $wtSettingsPaths) {
    $wtSettingsPath = $wtEntry.Path
    $pkgName = $wtEntry.PackageName
    $label = if ($wtEntry.IsPreview) { "Preview" } else { "Stable" }

    Write-Host "Configuring $pkgName ($label)..." -ForegroundColor Yellow

    # Backup settings
    $backupPath = "$wtSettingsPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $wtSettingsPath -Destination $backupPath -Force
    log_info "  Backup created: $(Split-Path $backupPath -Leaf)"

    # Load settings
    try {
        $settings = Get-Content $wtSettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        log_error "  Failed to parse settings.json: $_"
        $failCount++
        continue
    }

    # Set default font for all profiles
    $settings.profiles.defaults = [PSCustomObject]@{
        font = [PSCustomObject]@{
            face = $fontConfig.DisplayName
            size = $fontConfig.Size
        }
    }

    # Also set font for PowerShell profiles specifically
    $pwshProfiles = $settings.profiles.list | Where-Object {
        $_.name -like "*PowerShell*" -or $_.source -eq "Windows.Terminal.PowershellCore"
    }

    foreach ($profile in $pwshProfiles) {
        if (-not $profile.font) {
            $profile | Add-Member -NotePropertyName "font" -NotePropertyValue @{
                face = $fontConfig.DisplayName
                size = $fontConfig.Size
            } -Force
        } else {
            $profile.font.face = $fontConfig.DisplayName
            if (-not $profile.font.size) {
                $profile.font | Add-Member -NotePropertyName "size" -NotePropertyValue $fontConfig.Size -Force
            }
        }
    }

    # Save settings
    try {
        $settings | ConvertTo-Json -Depth 100 | Set-Content -Path $wtSettingsPath -Encoding UTF8 -Force
        log_info "  ✓ Configured $($pwshProfiles.Count) PowerShell profile(s)"
        $successCount++
    } catch {
        log_error "  Failed to save settings: $_"
        log_error "  Restoring backup..."
        Copy-Item -Path $backupPath -Destination $wtSettingsPath -Force
        $failCount++
    }

    Write-Host ""
}

# Summary
Write-Host "=== Configuration Summary ===" -ForegroundColor Cyan
log_info "Successfully configured: $successCount installation(s)"
if ($failCount -gt 0) {
    log_error "Failed: $failCount installation(s)"
}
Write-Host ""

if ($successCount -gt 0) {
    log_warn "IMPORTANT: Please restart Windows Terminal for changes to take effect."
    Write-Host ""
    log_info "To verify:"
    log_info "  1. Close all Windows Terminal windows"
    log_info "  2. Open Windows Terminal"
    log_info "  3. You should see icons properly displayed in oh-my-posh prompt"
    Write-Host ""
}

if ($failCount -gt 0) {
    exit 1
}
