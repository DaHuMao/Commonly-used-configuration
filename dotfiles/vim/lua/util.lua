

local M = {}
M.exists = function(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true, "success"
    end
  end
  return ok, err
end

M.replace = function (str, src, dest)
  local index = str:find(src, 1, true)
  local last_index = 1
  local ans = ''
  while index ~= nil and index >= last_index do
    ans = ans .. str:sub(last_index, index - 1) .. dest
    last_index = index + #src
    index = str:find(src, last_index, true)
  end
  if last_index <= #str then
    ans = ans .. str:sub(last_index, #str)
  end
  return ans
end

M.init = function(file_dir, unload_plugins)
  local config_dir = vim.fn.stdpath('config') .. '/lua/' .. file_dir
  -- plugins do not need to load, NOTE: no .lua suffix required
  if unload_plugins == nil then
    unload_plugins = {}
  end

  local helper_set = {}
  helper_set["init.lua"] = true
  for _, v in pairs(unload_plugins) do
    helper_set[v] = true
  end
  for _, fname in pairs(vim.fn.readdir(config_dir)) do
    if helper_set[fname] == nil then
      local cut_suffix_fname = fname
      local dot_index = fname:find('.', 1, true)
      local is_require_file = true
      if dot_index ~= nil then
        cut_suffix_fname = fname:sub(1, dot_index - 1)
        is_require_file = fname:sub(-4) == '.lua'
      else
        local file_absolute_path = config_dir .. "/" .. fname .. "/init.lua"
        is_require_file, _ = M.exists(file_absolute_path)
      end
      if is_require_file then
        local file = M.replace(file_dir, '/', '.') .. '.' .. cut_suffix_fname
        local status_ok, _ = pcall(require, file)
        if not status_ok then
          vim.notify('Failed loading ' .. file, vim.log.levels.ERROR)
        end
      end
    end
  end
end

M.get_home_dir = function()
  local home_dir = os.getenv("HOME")
  local is_windows = package.config:sub(1,1) == '\\'
  if is_windows then
    home_dir = os.getenv("USERPROFILE")
  end
  if not home_dir then
    vim.notify('can not find HOME', vim.log.levels.ERROR)
    return nil
  end
  return home_dir
end

-- 检查log文件大小，如果超过最大大小则保留最新的部分
-- @param log_file: log文件路径
-- @param max_size: 最大大小（字节）
-- @param keep_size: 保留大小（字节），默认为0
M.check_log_size = function(log_file, max_size, keep_size)
  keep_size = keep_size or 0

  local file = io.open(log_file, "r")
  if not file then
    return
  end

  file:seek("end")
  local file_size = file:tell()
  file:close()

  if file_size <= max_size then
    return
  end

  -- 超过最大大小，需要截断
  file = io.open(log_file, "r")
  local content = file:read("*a")
  file:close()

  -- 计算需要保留的内容
  local skip_size = file_size - keep_size
  local keep_content = content:sub(skip_size + 1)

  -- 写回文件
  file = io.open(log_file, "w")
  file:write(keep_content)
  file:close()
end

return M

