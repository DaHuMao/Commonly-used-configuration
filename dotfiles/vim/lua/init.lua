require "env"
require "plugin"
require "windows_manager".setup()

-- 只在C++文件中加载cpp_file_genaration插件
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.cc", "*.cpp", "*.cxx", "*.h", "*.hpp"},
  callback = function()
    require "cpp_file_genaration"
  end,
  group = vim.api.nvim_create_augroup("CppFileGeneration", { clear = true })
})

-- 退出时恢复终端光标形状为竖线
vim.api.nvim_create_autocmd("VimLeave", {
  pattern = "*",
  callback = function()
    -- 使用多种方式确保光标恢复
    vim.cmd([[
      set guicursor=
      silent !printf '\033[5 q'
    ]])
    io.write('\27[5 q')
    io.flush()
  end,
  group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true })
})

require ("nvim_function").setup()
require("key_map").setup()
vim.cmd.colorscheme "catppuccin"
vim.cmd [[autocmd BufRead,BufNewFile *.ets set filetype=typescript]]
