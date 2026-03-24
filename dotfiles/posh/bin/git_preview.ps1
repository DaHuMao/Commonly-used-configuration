param (
    [int]$num,
    [string]$str
)

$strArray = $str.Trim() -split '\s+'
$str1=$strArray[0]
$str2=$strArray[1]

if ($num -eq 1) {
    if ($strArray[0] -eq '??') {
        if (Test-Path -Path $strArray[1] -PathType Container) {
            # 如果是目录，使用 tree 查看
            Write-Host "tree ${strArray[1]}"
            tree $strArray[1]
        } else {
            # 否则使用自定义的文件高亮命令
            Write-Host "bat ${strArray[1]}"
            bat --color=always $strArray[1]
        }
    } else {
        Write-Host "command git diff $str2} | diff-so-fancy --colors"
        git diff $strArray[1] | diff-so-fancy --colors
    }
} elseif ($num -eq 0) {
    Write-Host "command git show $strArray[0] | diff-so-fancy --colors"
    git show $strArray[0] | diff-so-fancy --colors
}

