# 设置 oh-my-posh 主题路径
if (-not $env:POSH_THEMES_PATH) {
    # Try to load from cache first
    $cacheFile = "$env:TEMP\.posh_themes_path_cache"
    $cacheValid = $false

    if (Test-Path $cacheFile) {
        $cacheContent = Get-Content $cacheFile -Raw -ErrorAction SilentlyContinue
        if ($cacheContent -and (Test-Path $cacheContent.Trim())) {
            $env:POSH_THEMES_PATH = $cacheContent.Trim()
            $cacheValid = $true
            # log_info "POSH_THEMES_PATH loaded from cache: $env:POSH_THEMES_PATH"
        }
    }

    if (-not $cacheValid) {
        $ohmyposhPath = (Get-Command oh-my-posh -ErrorAction SilentlyContinue).Source
        if ($ohmyposhPath) {
            # Check if oh-my-posh is installed via Microsoft Store/winget
            if ($ohmyposhPath -like "*WindowsApps*") {
                # For winget/Store installs, get the package location
                $packagePath = (Get-AppxPackage | Where-Object { $_.Name -like "*OhMyPosh*" } | Select-Object -First 1).InstallLocation
                if ($packagePath -and (Test-Path $packagePath)) {
                    $env:POSH_THEMES_PATH = Join-Path -Path $packagePath -ChildPath "themes"
                    # Cache the path for future sessions
                    $env:POSH_THEMES_PATH | Out-File -FilePath $cacheFile -NoNewline -Force
                    log_info "POSH_THEMES_PATH set to: $env:POSH_THEMES_PATH"
                } else {
                    log_warn "Could not locate oh-my-posh package installation"
                }
            } else {
                # For other installations (scoop, manual, etc.)
                $ohmyposhDir = Split-Path -Path $ohmyposhPath -Parent
                $env:POSH_THEMES_PATH = Join-Path -Path $ohmyposhDir -ChildPath "..\themes"
                $env:POSH_THEMES_PATH = [System.IO.Path]::GetFullPath($env:POSH_THEMES_PATH)
                # Cache the path
                $env:POSH_THEMES_PATH | Out-File -FilePath $cacheFile -NoNewline -Force
                log_info "POSH_THEMES_PATH set to: $env:POSH_THEMES_PATH"
            }
        } else {
            log_warn "oh-my-posh not found in PATH"
        }
    }
}
$nvmPath = (Get-Command nvm -ErrorAction SilentlyContinue).Source
if ($nvmPath) {
  $nvmBaseDir = Split-Path -Path $nvmPath -Parent
  $nodeRoot   = Join-Path -Path $nvmBaseDir -ChildPath "nodejs"

  if (Test-Path -LiteralPath $nodeRoot) {
    $nodeDirs = Get-ChildItem -Path $nodeRoot -Directory -ErrorAction SilentlyContinue |
      Sort-Object -Property { [version]($_.Name.TrimStart('v')) } -Descending

    if ($nodeDirs -and $nodeDirs.Count -gt 0) {
      $latestNodeDir = $nodeDirs[0]
      $nodeExePath   = Join-Path -Path $latestNodeDir.FullName -ChildPath "node.exe"
      $node64ExePath = Join-Path -Path $latestNodeDir.FullName -ChildPath "node64.exe"

      if ($nodeExePath -and (Test-Path -LiteralPath $nodeExePath)) {
        $env:VIM_USED_NODE_BIN = $nodeExePath
        log_info "find node in $nodeExePath"
      } elseif ($node64ExePath -and (Test-Path -LiteralPath $node64ExePath)) {
        $env:VIM_USED_NODE_BIN = $node64ExePath
        log_info "find node in $node64ExePath"
      } else {
        log_error "node not found in $($latestNodeDir.FullName)"
      }
    } else {
      log_error "no node version directories found in $nodeRoot"
    }
  } else {
    log_error "nodejs directory not found under $nvmBaseDir"
  }
} else {
  log_error "nvm not found, please install nvm and make sure it is in the system PATH."
}

$gitPath = (Get-Command git -ErrorAction SilentlyContinue).Source

if ($gitPath) {
  $gitDir = Split-Path -Path (Split-Path -Path $gitPath -Parent) -Parent

  $bashPath = Join-Path -Path $gitDir -ChildPath "bin\bash.exe"
  $zshPath = Join-Path -Path $gitDir -ChildPath "bin\zsh.exe"

  if (Test-Path $bashPath) {
    Set-Alias -Name bash -Value $bashPath
      log_info "'bash' alias to $bashPath"
  } else {
    log_warn "$bashPath is not found"
  }

  if (Test-Path $zshPath) {
    Set-Alias -Name zsh -Value $zshPath
      log_info "'zsh' alias to $zshPath"
  } else {
    log_warn "$zshPath is not found"
  }
} else {
  log_error "git not found, please install git and make sure it is in the system PATH."
}

#检测是否安装了 neovim
if (Get-Command nvim -ErrorAction SilentlyContinue) {
  Set-Alias -Name vim -Value nvim
    Set-Alias -Name vi -Value nvim
}

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
  Set-Alias -Name code -Value "E:\software\Microsoft VS Code\bin\code.cmd"
}


$env:DEPOT_TOOLS_UPDATE = 0


function review {
  $branch_name = $(git rev-parse --abbrev-ref HEAD)
    if (-not $branch_name ) {
      log_error "! [Branch name missing]"
        log_error "please try in a git repository"
        return
    }
  $reviewers = "r=wangcb,r=pengyang,r=zhaoguanxun,r=zhufan,r=gaocy01,r=liguang,r=zhangzhebj03,r=gaoyubj03"
    git push origin HEAD:refs/for/${branch_name}%${reviewers}
}

