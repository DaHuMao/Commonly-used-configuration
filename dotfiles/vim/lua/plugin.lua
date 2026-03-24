local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  vim.notify("Failed to load lazy.nvim", vim.log.levels.ERROR)
  return
end

-- 渐进式迁移：从自定义目录 lazy_vim_plugin 加载插件配置
-- 使用 import 参数可以让 lazy.nvim 自动加载指定模块下的所有 .lua 文件
require("lazy").setup({
  -- 导入 lazy_vim_plugin 目录下的所有配置文件
  { import = "lazy_vim_plugin" },
}, {
  performance = {
    reset_packpath = false, -- 不重置 packpath，让 packer 的插件继续可用
  },
  -- 不自动检查更新，避免干扰
  checker = {
    enabled = false,
  },
  -- 不显示变更日志
  change_detection = {
    enabled = false,
  },
})



