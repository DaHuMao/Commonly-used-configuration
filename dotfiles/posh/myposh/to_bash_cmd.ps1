# Helper function to remove aliases (compatible with PowerShell 5.x and 7+)
function Remove-AliasIfExists {
    param([string]$Name)
    if (Test-Path "Alias:$Name") {
        if (Get-Command Remove-Alias -ErrorAction SilentlyContinue) {
            Remove-Alias -Name $Name -Force -ErrorAction SilentlyContinue
        } else {
            # For PowerShell 5.x, use Remove-Item
            Remove-Item "Alias:$Name" -Force -ErrorAction SilentlyContinue
        }
    }
}

function touch {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,

        [switch]$p  # -p 选项用于递归创建目录
    )

    $directory = Split-Path -Path $Path -Parent

    # 如果启用了递归创建目录并且目录不存在，创建目录
    if ($p.IsPresent -and -not (Test-Path $directory)) {
        try {
            New-Item -ItemType Directory -Path $directory -Force
            log_info "Created directory '$directory'"
        } catch {
            log_error "Failed to create directory '$directory':$_"
        }
    }

    if (Test-Path $Path) {
        # 如果文件存在，打印一条日志而不更新时间
        log_info "File '$Path' already exists. No update performed."
    } else {
        # 如果文件不存在，创建文件
        try {
            New-Item -ItemType File -Path $Path
            log_info "Created new file '$Path'"
        } catch {
            Write-Error "Failed to create new file '$Path':$_"
        }
    }
}

function mklink {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$src,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$tar
    )

    # 转换路径为绝对路径
    $srcPath = Resolve-Path -Path $src
    $tarPath = $tar

    try {
        # 使用 New-Item 创建符号链接
        New-Item -ItemType SymbolicLink -Path $tarPath -Target $srcPath
        log_info "mklink: ${tar} -> ${src}"
    } catch {
        log_error "can not mklink: $_"
    }
}

function which {
    param (
        [Parameter(Mandatory = $true)]
        [string]$command
    )

    # 查找命令并输出其路径
    $result = Get-Command $command -ErrorAction SilentlyContinue
    if ($null -ne$result) {
        $result | Select-Object -ExpandProperty Definition
    } else {
        log_info "${command}: command not found"
    }
}

function mkfile_and_mv {
    param (
        [string]$filePath
    )

    if (Test-Path $filePath) {
        # 文件存在
        $backupPath = "$filePath.bak"
        Move-Item -Path $filePath -Destination $backupPath -Force
        log_warn "$filePath has been moved to $backupPath"
    } else {
        log_info "$filePath does not exist, no need to move or backup"
    }
}

function mkdir_and_rm {
    param (
        [string]$dirPath
    )

    if (Test-Path $dirPath) {
        # 目录存在，删除它
        Remove-Item -Path $dirPath -Recurse -Force
        log_warn "Removed existing directory $dirPath"
    }
    # 创建目录
    New-Item -Path $dirPath -ItemType Directory -Force
    log_info "Created directory $dirPath"
}

function export {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$VariableName,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]$Value,

        [Parameter(Position = 2, Mandatory = $false)]
        [ValidateSet('Process', 'User', 'Machine')]
        [string]$Scope = 'Process'
    )

    # 检查变量名 是否传递
    if ([string]::IsNullOrEmpty($VariableName)) {
        log_error "Variable name is empty or null."
        return
    }

    # 设置变量
     try {
        [System.Environment]::SetEnvironmentVariable($VariableName,$Value, $Scope)
        if ($Scope -eq 'Process') {
          ${Env:$VariableName} =$Value
        }
        log_info "Environment variable '$VariableName' set to '$Value' in scope '$Scope'."
    } catch {
        log_error "Error setting environment variable: $_"
    }
}

function open {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path
    )

    # 检查路径有效性
    if (-Not (Test-Path $Path)) {
        log_error "Invalid path: $Path"
        return
    }

    # 获取完整路径
    $fullPath = Resolve-Path $Path

    # 打开文件或者目录
    try {
        Start-Process -FilePath $fullPath
        log_info "Opened: $Path"
    } catch {
        log_error "Failed to open: $Path"
        log_error "Error: $_"
    }
}

if (Test-Path Alias:rm) {
   Remove-AliasIfExists cp
}
function cp {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
        [string[]] $Paths,

        [switch] $r
    )

    # 检查参数数量是否至少为2（至少一个源文件和一个目标路径）
    if ($Paths.Count -lt 2) {
        log_error "At least one source file and one destination path are required."
        return
    }

    # 分离源文件和目标路径
    $Sources = @($Paths | Select-Object -SkipLast 1)
    $Destination = $Paths[-1]

    # 解析所有源文件路径
    $resolvedSources = @()
    foreach ($Source in $Sources) {
        $resolvedPath = Resolve-Path $Source -ErrorAction SilentlyContinue
        if ($resolvedPath) {
            $resolvedSources += $resolvedPath
        } else {
          log_warn "Source file '$Source' not found, skipping."
        }
    }

    # 如果没有有效的源文件，则直接返回
    if (-not $resolvedSources) {
        log_error "No valid source files to copy."
        return
    }

    # 当复制多个文件时，检查目标路径是否为目录
    if ($resolvedSources.Count -gt 1) {
        if (-not (Test-Path $Destination -PathType Container)) {
          log_error "When copying multiple files, the destination must be a directory."
          return
        }
    }

    foreach ($Source in $resolvedSources) {
        if (Test-Path $Source -PathType Container) {
            if (-not $r) {
                log_warn "Use -r option to copy directory '$Source', skipping."
            }
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        } else {
            if (Test-Path $Destination -PathType Container) {
                $DestinationPath = Join-Path $Destination (Split-Path $Source -Leaf)
            } else {
                $DestinationPath = $Destination
            }
            Copy-Item -Path $Source -Destination $DestinationPath -Force
        }
    }
}

if (Test-Path Alias:rm) {
  Remove-AliasIfExists rm
}
function rm {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
        [string[]] $Paths,

        [switch] $r,  # 递归删除
        [switch] $f   # 强制删除（在这里我们简单处理为不提示确认）
    )

    # 检查是否同时使用了 -r 和 -f，并设置递归和强制标志
    $recursive = $r.IsPresent
    $force = $f.IsPresent

    foreach ($pathPattern in $Paths) {
        # 解析通配符并获取实际路径
        $resolvedPaths = Resolve-Path -Path $pathPattern -ErrorAction SilentlyContinue

        if (-not $resolvedPaths) {
            log_error "Path not found: $pathPattern"
            return
        }

        foreach ($path in $resolvedPaths) {
            if (Test-Path -Path $path -PathType Container) {
                if ($recursive) {
                    try {
                      Remove-Item -Path $path -Recurse -Force
                      log_info "Removed directory: $path"
                    } catch {
                      log_error "Failed to remove directory: $path. $_"
                    }
                } else {
                    log_error "Directory found but -r not specified: $path"
                    return
                }
            } elseif (Test-Path -Path $path -PathType Leaf) {
                # 处理文件
                try {
                  Remove-Item -Path $path -Force
                  log_info "Removed file: $path"
                } catch {
                  log_error "Failed to remove file: $path. $_"
                }
            } else {
                log_error "Path does not exist or is not accessible: $path"
            }
        }
    }
}

if (Test-Path Alias:ls) {
    Remove-AliasIfExists ls
}

function ls {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Path = ".",
        [switch]$l,
        [switch]$r
    )

    # 解析路径
    $resolvedPaths = foreach ($p in $Path) {
        try {
            Resolve-Path -Path $p -ErrorAction Stop | Select-Object -ExpandProperty Path
        } catch {
            Write-Error "Path not found: $p"
            continue
        }
    }

    # 获取文件列表
    $items = if ($r) {
        $resolvedPaths | ForEach-Object {
            Get-ChildItem -Path $_ -Recurse -ErrorAction SilentlyContinue |
            ForEach-Object {
                $relativePath = $_.FullName.Substring((Get-Location).Path.Length + 1)
                $_ | Add-Member -NotePropertyName "RelativePath" -NotePropertyValue $relativePath -PassThru
            }
        }
    } else {
        $resolvedPaths | ForEach-Object { Get-ChildItem -Path $_ -ErrorAction SilentlyContinue }
    }

    # 详细模式或递归模式处理
    if ($l -or $r) {
        if ($items.Count -gt 30) {
            Write-Warning "Showing first 30 of $($items.Count) items."
            $items = $items | Select-Object -First 30
        }

        # 详细模式（-l）
        if ($l) {
            $formattedItems = foreach ($item in $items) {
                $name = if ($r) { $item.RelativePath } else { $item.Name }
                $colorName = if ($item.PSIsContainer) {
                  "$([char]0x1B)[34m$name$([char]0x1B)[0m"  # 使用十六进制ANSI ESC字符
                } else {
                  $name
                }

                $modeChar = if ($item.PSIsContainer) { "d" } else { "-" }
                $perm = if ($item.Attributes -band [System.IO.FileAttributes]::ReadOnly) { "r--" } else { "rw-" }
                $size = if ($item.PSIsContainer) {
                  "-"
                } else {
                  $length = $item.Length
                    switch ($length) {
                      { $_ -ge 1GB } { "{0:N1}G" -f ($_ / 1GB); break }
                      { $_ -ge 1MB } { "{0:N1}M" -f ($_ / 1MB); break }
                      { $_ -ge 1KB } { "{0:N1}K" -f ($_ / 1KB); break }
                      default { "{0}B" -f $_ }
                    }
                }


                $obj = New-Object PSObject -Property @{
                    Mode = $modeChar + $perm
                    LastWrite = $item.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
                    Size = $size
                    Name = $colorName
                }
                $obj
            }

            $PSStyle.OutputRendering = 'Ansi'
            $formattedItems | Format-Table -Property @(
                @{ Label = "Mode"; Expression = { $_.Mode }; Width = 5 },
                @{ Label = "LastWrite"; Expression = { $_.LastWrite }; Width = 18 },
                @{ Label = "Size"; Expression = { $_.Size }; Width = 7 },
                @{ Label = "Name"; Expression = { $_.Name } }
            ) | Out-String -Stream | ForEach-Object {
                if ($_ -match '^(.{27}\s+)(\S+)') {
                    $_.Substring(0, 27) + '    ' + $_.Substring(27).TrimStart()
                } else {
                    $_
                }
            }
            $PSStyle.OutputRendering = 'Host'
        }
        # 仅递归模式（-r）
        else {
            $items | ForEach-Object {
                if ($_.PSIsContainer) {
                    Write-Host $_.RelativePath -ForegroundColor Blue -NoNewline
                } else {
                    Write-Host $_.RelativePath -NoNewline
                }
                Write-Host " " -NoNewline
            }
            Write-Host ""
        }
        return
    }

    # 默认模式：Unix风格多列输出
    $maxWidth = $Host.UI.RawUI.WindowSize.Width
    $colWidth = ($items | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum + 4
    $cols = [Math]::Max(1, [Math]::Floor($maxWidth / $colWidth))

    $i = 0
    foreach ($item in $items) {
        $displayName = $item.Name.PadRight($colWidth)
        if ($item.PSIsContainer) {
            Write-Host $displayName -ForegroundColor Blue -NoNewline
        } else {
            Write-Host $displayName -NoNewline
        }

        $i++
        if ($i % $cols -eq 0) { Write-Host "" }
    }
    if ($i % $cols -ne 0) { Write-Host "" }
}

#move
if (Test-Path Alias:mv) {
    Remove-AliasIfExists mv
}

function mv {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
        [string[]] $Paths,

        [switch] $f  # 强制覆盖
    )

    # 检查参数数量是否至少为2（至少一个源文件和一个目标路径）
    if ($Paths.Count -lt 2) {
        log_error "At least one source file and one destination path are required."
        return
    }

    # 分离源文件和目标路径
    $Sources = @($Paths | Select-Object -SkipLast 1)
    $Destination = $Paths[-1]

    # 解析所有源文件路径
    $resolvedSources = @()
    foreach ($Source in $Sources) {
        $resolvedPath = Resolve-Path $Source -ErrorAction SilentlyContinue
        if ($resolvedPath) {
            $resolvedSources += $resolvedPath
        } else {
          log_warn "Source file '$Source' not found, skipping."
        }
    }

    # 如果没有有效的源文件，则直接返回
    if (-not $resolvedSources) {
        log_error "No valid source files to move."
        return
    }

    # 当移动多个文件时，检查目标路径是否为目录
    if ($resolvedSources.Count -gt 1) {
        if (-not (Test-Path $Destination -PathType Container)) {
          log_error "When moving multiple files, the destination must be a directory."
          return
        }
    }

    foreach ($Source in $resolvedSources) {
        if (Test-Path $Source -PathType Container) {
            Move-Item -Path $Source -Destination $Destination -Force:$f.IsPresent
            log_info "Moved directory: $Source to $Destination"
        } else {
            if (Test-Path $Destination -PathType Container) {
                $DestinationPath = Join-Path $Destination (Split-Path $Source -Leaf)
            } else {
                $DestinationPath = $Destination
            }
            Move-Item -Path $Source -Destination $DestinationPath -Force:$f.IsPresent
            log_info "Moved file: $Source to $Destination"
        }
    }
}
