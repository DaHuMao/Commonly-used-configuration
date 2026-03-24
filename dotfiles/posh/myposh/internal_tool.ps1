function get_buffer {
  $line = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, $null)
  return $line
}

function get_lbuffer {
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,
      [ref]$cursor)
  return $line.Substring(0, $cursor)
}

function get_rbuffer {
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,
      [ref]$cursor)
  return $line.Substring($cursor)
}

function append_buffer {
    param (
        [string]$newContent
    )
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($newContent)
}

function clear_buffer {
    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
}

function update_buffer {
    param (
        [string]$newContent
    )
    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($newContent)
}

function update_lbuffer {
  param (
      [string]$newContent
  )
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,
      [ref]$cursor)
  $line = $newContent + $line.Substring($cursor)
  clear_buffer
  append_buffer $line
}

function update_rbuffer {
  param (
      [string]$newContent
  )
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,
      [ref]$cursor)
  $line = $line.Substring(0, $cursor) + $newContent
  clear_buffer
  append_buffer $line
}

function cursor_position {
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState().CursorPosition
}

function set_cursor_position {
    param (
        [int]$newPosition
    )
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($newPosition)
}

function find_next_nonsapce {
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,
      [ref]$cursor)
  $find_space = $false
  while ($cursor -lt $line.Length) {
    $curr_char =$line[$cursor]
    if ($curr_char -eq ' ') {
      $find_space = $true
    }
    if ($find_space -and $curr_char -ne ' ') {
      break
    }
    $cursor++
  }
  set_cursor_position $cursor
}

function find_pre_nonsapce {
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,
      [ref]$cursor)
  $find_space = $false
  $cursor--
  while ($cursor -gt 0) {
    $curr_char =$line[$cursor]
    if ($curr_char -eq ' ') {
      $find_space = $true
    }
    if ($find_space -and $curr_char -ne ' ') {
      $cursor++
      break
    }
    $cursor--
  }
  set_cursor_position $cursor
}


