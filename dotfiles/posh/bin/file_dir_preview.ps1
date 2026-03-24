param (
    [string]$file_or_dir1,
    [string]$file_or_dir2
)

$file_or_dir = "$file_or_dir1\$file_or_dir2"
Write-Output $file_or_dir

function Check-FileTypeAndSize {
    param (
        [string]$filePath
    )

    # Check if file is a text file
    $isText = (Get-Content$filePath -Raw -ErrorAction Ignore | Select-String -Pattern '[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\xff]').Length -eq 0

    # Get file size in bytes
    $fileSize = (Get-Item$filePath).Length

    # If file is not a text file and file size is larger than 1MB (1048576 bytes)
    if (-not $isText -and$fileSize -gt 1048576) {
        return 0
    }
    return 1
}

if (Test-Path -Path $file_or_dir -PathType Leaf) {
    Write-Output "$env:FZF_FILE_HIGHLIGHTER$file_or_dir"
    $isText = Check-FileTypeAndSize$file_or_dir
    if ($isText -eq 0) {
        more $file_or_dir
    } else {
        Invoke-Expression "$env:FZF_FILE_HIGHLIGHTER$file_or_dir"
    }
} elseif (Test-Path -Path $file_or_dir -PathType Container) {
    tree $file_or_dir
}

