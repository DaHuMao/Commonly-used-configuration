

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

return M

