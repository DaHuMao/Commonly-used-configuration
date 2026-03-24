function log_info {
    param (
        [Parameter(Mandatory = $true)]
        [string]$message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] INFO: $message" -ForegroundColor Green
}

function log_warn {
    param (
        [Parameter(Mandatory = $true)]
        [string]$message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] WARN: $message" -ForegroundColor Yellow
}

function log_error {
    param (
        [Parameter(Mandatory = $true)]
        [string]$message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] ERROR: $message" -ForegroundColor Red
}

function log_abort {
    param (
        [Parameter(Mandatory = $true)]
        [string]$message
    )

    log_error $message
    exit 1
}

function measure_exe_runtime {
    param (
        [Parameter(Mandatory = $false)]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [string]$Command,

        [Parameter(Mandatory = $false)]
        [string]$Description = "Execution"
    )

    $startTime = Get-Date
    if ($Command) {
      Invoke-Expression $Command
    } elseif ($ScriptBlock) {
      & $ScriptBlock
    } else {
        log_error "No script block or command provided"
        return
    }
    $endTime = Get-Date

    # 计算时间差并输出结果
    $elapsedTime =$endTime - $startTime
    log_info "${Description} Time: $($elapsedTime.TotalSeconds) seconds"
}

function time_diff {
    param (
        [Parameter(Mandatory = $true)]
        [datetime]$StartTime
    )
    $nowTime = Get-Date
    $elapsedTime = $nowTime - $StartTime
    $elapsedTime.TotalSeconds
}

function add_path_env {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$PathToAdd,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateSet('Process', 'User', 'Machine')]
        [string]$Scope = 'Process'
    )

    # Get the current PATH environment variable
    switch ($Scope) {
        'Process' { $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Process") }
        'User' { $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User") }
        'Machine' { $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") }
    }

    # Check path validity
    if (-Not (Test-Path $PathToAdd)) {
        log_error "Invalid path: $PathToAdd"
        return
    }

    # Check if the path already exists in PATH
    if ($currentPath -split ';' | ForEach-Object {$_.Trim() } | Where-Object { $_ -eq$PathToAdd }) {
        log_warn "Path already exists in PATH: $PathToAdd"
        return
    }

    # Add path to PATH and set the new environment variable
    $newPath = "$currentPath;$PathToAdd"
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath,$Scope)
    log_info "Path has been added to PATH: $PathToAdd"
}

function test-administrator {
    return [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function install_or_update {
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$package_name,

    [Parameter(Position = 1, Mandatory = $false)]
    [string]$command
  )

  if (-not $command) {
    $command = $package_name
  }
  if (Get-Command $command -ErrorAction SilentlyContinue) {
    log_info "Command $command already exists"
    scoop update $package_name
  } else {
    log_info "Installing $command"
    scoop install $package_name
  }
}

