
require("mason").setup()

local M = {}

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

M.init = function(file_dir)
  local config_dir = vim.fn.stdpath('config') .. '/lua/' .. file_dir
  -- plugins do not need to load, NOTE: no .lua suffix required
  local unload_plugins = {
    "init", -- we don't need to load init again
  }

  local helper_set = {}
  for _, v in pairs(unload_plugins) do
    helper_set[v] = true
  end
  for _, fname in pairs(vim.fn.readdir(config_dir)) do
    local cut_suffix_fname = fname
    local dot_index = fname:find('.', 1, true)
    if dot_index ~= nil then
      cut_suffix_fname = fname:sub(1, dot_index - 1)
    end
    if helper_set[cut_suffix_fname] == nil then
      local file = M.replace(file_dir, '/', '.') .. '.' .. cut_suffix_fname
      local status_ok, _ = pcall(require, file)
      if not status_ok then
        vim.notify('Failed loading ' .. file, vim.log.levels.ERROR)
      end
    end
  end
end

return M

