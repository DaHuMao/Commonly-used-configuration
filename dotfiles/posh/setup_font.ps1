<#
    全自动 Nerd Font 安装与 Windows Terminal 字体配置脚本

    功能：
    - 使用现有 font_config.ps1 / install_font.ps1 安装 Nerd Font
    - 自动查找 Windows Terminal 的 settings.json
    - 将 profiles.defaults.font.face / size 设置为配置中的 DisplayName / Size

    使用方式（在 dotfiles\posh 目录下）：
        pwsh -File .\setup_font.ps1

    或者任意目录（建议）：
        pwsh -File "C:\\Users\\Admin\\code\\Commonly-used-configuration\\dotfiles\\posh\\setup_font.ps1"
#>

param()

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# 引入日志工具与字体配置、安装函数
. "$scriptRoot/myposh/tool.ps1"
. "$scriptRoot/font_config.ps1"
. "$scriptRoot/install_font.ps1"

$fontConfig = Get-FontConfig

function Set-WindowsTerminalFont {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FontName,

        [Parameter(Mandatory = $false)]
        [int]$FontSize
    )

    # Windows Terminal（商店版）
    $storePath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    # Windows Terminal（免安装版）
    $unpackagedPath = Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json"

    $candidatePaths = @($storePath, $unpackagedPath) | Where-Object { Test-Path $_ }

    if (-not $candidatePaths -or $candidatePaths.Count -eq 0) {
        log_warn "未找到 Windows Terminal 的 settings.json，已跳过终端字体配置。"
        return $false
    }

    $success = $false

    foreach ($path in $candidatePaths) {
        try {
            log_info "正在配置 Windows Terminal 字体：$path"

            # 备份原配置
            $backupPath = "$path.bak"
            if (-not (Test-Path $backupPath)) {
                Copy-Item $path $backupPath -ErrorAction SilentlyContinue
                log_info "已创建备份：$backupPath"
            }

            $jsonText = Get-Content $path -Raw -ErrorAction Stop
            $settings = $jsonText | ConvertFrom-Json -ErrorAction Stop

            if (-not $settings.profiles) {
                $settings | Add-Member -NotePropertyName 'profiles' -NotePropertyValue (@{})
            }

            if (-not $settings.profiles.defaults) {
                $settings.profiles | Add-Member -NotePropertyName 'defaults' -NotePropertyValue (@{})
            }

            if (-not $settings.profiles.defaults.font) {
                $settings.profiles.defaults | Add-Member -NotePropertyName 'font' -NotePropertyValue (@{})
            }

            $settings.profiles.defaults.font.face = $FontName
            if ($FontSize) {
                $settings.profiles.defaults.font.size = $FontSize
            }

            $settings | ConvertTo-Json -Depth 10 | Set-Content $path -Encoding UTF8

            log_info "已将 Windows Terminal 默认字体设置为：$FontName (size: $FontSize)"
            $success = $true
        }
        catch {
            log_warn "配置 Windows Terminal 字体失败 ($path)：$_"
        }
    }

    return $success
}

log_info "=== 自动安装 Nerd Font 并配置 Windows Terminal 字体 ==="

# 检查 oh-my-posh 是否安装
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    log_error "oh-my-posh 未安装，无法自动安装 Nerd Font。"
    log_info "请先执行：winget install JanDeDobbeleer.OhMyPosh -s winget"
    exit 1
}

log_info "当前字体配置：$($fontConfig.DisplayName) (文件：$($fontConfig.FilePattern)，大小：$($fontConfig.Size))"

$fontStatus = Test-NerdFont

if ($fontStatus.Installed) {
    log_info "检测到 Nerd Font 已安装（$($fontStatus.Scope)）：$($fontStatus.Path)"
} else {
    log_info "未检测到 Nerd Font，正在安装..."
    if (-not (Install-NerdFont -Silent)) {
        log_error "自动安装 Nerd Font 失败，已退出。"
        exit 1
    }
}

log_info "正在配置 Windows Terminal 使用 Nerd Font..."

if (Set-WindowsTerminalFont -FontName $fontConfig.DisplayName -FontSize $fontConfig.Size) {
    log_info "✓ 已自动完成字体安装与 Windows Terminal 配置。请重启 Windows Terminal 生效。"
    exit 0
} else {
    log_warn "字体安装已完成，但未找到 Windows Terminal 配置文件，请手动在终端设置中选择字体：$($fontConfig.DisplayName)"
    exit 0
}

