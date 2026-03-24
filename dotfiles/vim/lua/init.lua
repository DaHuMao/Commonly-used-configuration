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

require ("nvim_function").setup()
require("key_map").setup()
vim.cmd.colorscheme "catppuccin"
vim.cmd [[autocmd BufRead,BufNewFile *.ets set filetype=typescript]]
