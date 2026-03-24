#!/usr/bin/env pwsh

param (
    [string]$inputString,
    [string]$alternateFileName
)

# 分割字符串
$strArray =$inputString -split ':'
$fileName =$strArray[0]
$lineNum =$strArray[1]

# 检查是否有备用文件名
if ($alternateFileName) {
  $fileName = $alternateFileName
  $lineNum = $strArray[0]
}

# 计算预览的行号范围
$preLineNum =$lineNum - 15
if ($preLineNum -lt 0) {
  $preLineNum = 0
}

# 调用 bat 命令
bat --color=always `
--highlight-line $lineNum --theme=gruvbox-dark `
--line-range ${preLineNum}:$($lineNum + 15) ` $fileName

