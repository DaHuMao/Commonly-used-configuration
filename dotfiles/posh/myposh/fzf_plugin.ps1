
function find_history {
  $historyPath = "$env:USERPROFILE\Documents\PowerShell\PSReadLine_History.txt"
  $line = $null
  $select = $(cat $historyPath | fzf --query=$(get_lbuffer))
  if ($select) {
    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($select)
  }
}


function _fzf_compgen_path {
  param (
      [string]$params
  )
  fd --type f  --no-ignore-vcs --hidden --follow --exclude .git --base-directory $params | Out-String -Stream
}

function _fzf_compgen_dir {
  param (
      [string]$params
  )
  fd --type d  --no-ignore-vcs --hidden --follow  --exclude .git --base-directory $params | Out-String -Stream
}

function _fzf_compgen_all {
  param (
      [Parameter(ValueFromRemainingArguments = $true)]
      [string[]]$params
  )
  fd --no-ignore-vcs --hidden --follow --exclude .git @params | Out-String -Stream
}

function _git_status {
  param (
      [string]$params
  )
  if ([string]::IsNullOrEmpty($params)) {
    git status -s
  } else {
    invoke-Expression "git status -s | ${params}"
  }
}

function _git_log {
  git log --color=always --max-count=200 --pretty=format:'%C(yellow)%h%C(red) %ad%C(green)%d%C(reset) %s %C(blue)[%an]%C(reset)' --date=short
}

function _git_branch {
  git branch -a | sed 's:.*/::'
}

function _select_git_edit {
  param (
      [string[]]$str_arr,
      [int]$remainder
  )

  $ret_arr = @()
  for ($i = 0;$i -lt $str_arr.Length;$i++) {
      $ele_arr=$str_arr[$i] -split ' '
      $ret_arr += $ele_arr[$remainder]
  }
  Write-Output $ret_arr
}

function _common_selected {
  param (
      [string]$baseDir,
      [string]$str
  )
  $strArr=$str -split ' '
  if ($strArr.Length -eq 0) {
    return
  }
    # 去掉baseDir 最后的/
    $len =$strArr.Length
    $baseDir =$baseDir.TrimEnd('/')

    $resValue = ""

    for ($i = 0;$i -lt $strArr.Length;$i++) {
        if ([string]::IsNullOrWhiteSpace($strArr[$i])) {
            continue
        }
        $resValue += " $baseDir\$($strArr[$i])"
    }

    # 删除开头多余的空格
    $resValue =$resValue.TrimStart()

    return $resValue
}

function _find_prompt_file {
    param (
        [string]$searchDir,
        [string]$searchName
    )

    $searchName =$searchName.Trim()
    $match = ""

    $files = Get-ChildItem -Path $searchDir -Filter *.prompt

    foreach ($file in $files) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        if ($baseName -eq $searchName) {
            $match =$file.FullName
            break
        }
    }
    return $match
}

$global:git_log_prefix_function_map = @{
    "lg"      = "_git_log"
    "resf"    = "_git_log"
    "rehd"    = "_git_log"
    "rebase"  = "_git_log"
    "rbi"     = "_git_log"
    "revert"  = "_git_log"
}

$zsh_prompt_dir = "$HOME/.myzsh/custom_prompt"

$default_fzf_opt = " --ansi --wrap  --reverse --cycle --preview-window up:70%" +
  " --preview-window=hidden" +
  " --bind ctrl-/:toggle-preview,alt-w:toggle-preview-wrap" +
  " --bind ctrl-b:preview-half-page-up,ctrl-n:preview-half-page-down"

function fzf_common_selected {
    $LBUFFER = ""
      $searchName = $(get_lbuffer)
      $searchName = $searchName.Trim()

      if ([string]::IsNullOrEmpty($searchName)) {
        $LBUFFER = $(Get-Content "$zsh_prompt_dir/remind_cmd" | fzf --ansi)
          update_buffer $LBUFFER
          return
      }

    $matchFile = Get-ChildItem -Path $zsh_prompt_dir -Filter "$searchName.prompt" -File
      if (-not [string]::IsNullOrEmpty($matchFile)) {
        $LBuffer = Get-Content $matchFile.FullName | fzf --ansi
          update_buffer $LBuffer
          return
      }
    $LBUFFER = $(get_lbuffer)
      $tokens =$LBUFFER -split ' '
      $params = '-' + ($LBUFFER -split '--')[-1]
      $lbuf =$LBUFFER
      $cmd = ""
      $cmdParams = ""
      $fzfOpt = $default_fzf_opt
      $previewTool = ""
      $baseDir = "."
      $index = -1
      $is_multi_line = 1
      if ($tokens.Length -gt 0) {
        $headCmd = $tokens[0]
          if ($headCmd -eq "git") {
            $cmd = "_git_status"
            $index = 1
              if ($tokens.Length -gt 1) {
                $token2 = $tokens[1]
                  if ($git_log_prefix_function_map[$token2]) {
                    $cmd = $git_log_prefix_function_map[$token2]
                      $index = 0
                      $is_multi_line = 0
                  }
                elseif ($token2 -eq "diff" -or $token2 -eq "co") {
                  $cmdParams = " | rg '^ M|^MM|^ D'"
                }
                elseif ($token2 -eq "cob") {
                  $cmd = "_git_branch"
                    $index = 0
                    $preview_tool = ''
                    $lbuf = "git co "
                }
              }
            $previewTool = "pwsh -NoProfile $HOME/.myposh/bin/git_preview.ps1 $index {}"
          }else {
            $cmd="_fzf_compgen_all"
            if ($headCmd -eq "cd" -or $headCmd -eq "open" -or $headCmd -eq "mkdir" -or $headCmd -eq "touch" -or $LBuffer -match "cp -r") {
              $cmdParams = "--type d"
            }

            if ($tokens[-1] -match "^-d$") {
              $tokens =$tokens[0..($tokens.Length - 2)]
                $cmdParams += " --type d"
                tokens = $tokens[0..($tokens.Length - 2)]
            } elseif ($tokens[-1] -match "^-d\d+$") {
              $number = $tokens[-1].Replace("-d", "")
                $cmdParams += " --max-depth $number"
                $tokens = $tokens[0..($tokens.Length - 2)]
            }

            $hitDepthRule = $false
            # 新规则（按“末位字符”判断深度）：
            # 把最后一个 token 拆成两段：
            # - head = 第 1 个字符到倒数第 2 个字符（可能为空；为空时强制为 `.`）
            # - tail = 最后 1 个字符
            # 若 tail 是数字且 head 是目录：命中规则 -> 在该目录下做 `fd --max-depth <tail>` 深度搜索。
            # 例：`xx xxx A/B1` -> head=A/B, tail=1 -> 在 `A/B` 下 `fd --max-depth 1 ...`
            # 例：`xx xxx 1`    -> head=.,  tail=1 -> 在当前目录 `fd --max-depth 1 ...`
            if ($tokens.Length -gt 0) {
              $lastToken = $tokens[-1]
              if (-not [string]::IsNullOrEmpty($lastToken)) {
                $tail = $lastToken.Substring($lastToken.Length - 1, 1)
                $head = if ($lastToken.Length -gt 1) { $lastToken.Substring(0, $lastToken.Length - 1) } else { "" }
                if ([string]::IsNullOrEmpty($head)) { $head = "." }
                $head = $head.Replace("~", [System.Environment]::GetFolderPath("UserProfile"))

                if ($tail -match "^\d$") {
                  if (Test-Path -Path $head -PathType Container) {
                    $cmdParams += " --max-depth $tail"
                    $baseDir = $head
                    $dir = $baseDir
                    $hitDepthRule = $true
                    # 目录/深度信息已经编码在 lastToken 里，把它从命令前缀移除
                    $tokens = if ($tokens.Length -gt 1) { $tokens[0..($tokens.Length - 2)] } else { @() }
                  }
                }
              }
            }

            if (-not $hitDepthRule) {
              # 原逻辑：若最后一个 token 是目录，则把它当作 baseDir，并从 tokens 中移除。
              # 注意：这里要先判断长度，避免 tokens 为空时报错。
              if ($tokens.Length -gt 0) {
                $dir = $tokens[-1].Replace("~", [System.Environment]::GetFolderPath("UserProfile"))
                if (Test-Path -Path $dir -PathType Container) {
                  $baseDir = $dir
                  $tokens = if ($tokens.Length -gt 1) { $tokens[0..($tokens.Length - 2)] } else { @() }
                }
              } else {
                $dir = "."
              }
            }
            $cmdParams += " --base-directory $baseDir"
              $lbuf = ($tokens -join ' ')
              $previewTool = "pwsh -NoProfile $HOME/.myposh/bin/file_dir_preview.ps1 $dir {}"
          }
      }
    if ($is_multi_line -eq 1) {
      $fzfOpt = "--multi " + $fzfOpt
    }
    #echo "$cmd $cmdParams | fzf $fzfOpt --preview '$previewTool'" > ~/tmp.log
    $selected = $(invoke-Expression "$cmd $cmdParams | fzf $fzfOpt --preview '$previewTool'")
    $LBuffer = $lbuf
    #不是空字符串
    if ( -not [string]::IsNullOrEmpty($selected)) {
      $selected = $selected.Trim()
      if ($index -eq -1) {
        $LBuffer = "$lbuf $(_common_selected $baseDir $selected)"
      } else {
        $str=$(_select_git_edit $selected $index)
        $LBuffer = "$lbuf $str"
      }
      update_lbuffer $LBuffer
    }

}
