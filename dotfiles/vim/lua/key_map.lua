local function lsp_keymaps()
  local opts = { noremap = true, silent = true }
  -- 跳转到声明
  vim.api.nvim_set_keymap("n", "gd", "<cmd>Lspsaga Lspsaga peek_definition<CR>", opts)
  -- 跳转到定义
  vim.api.nvim_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  -- 显示注释文档
  vim.api.nvim_set_keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", opts)
  -- 跳转到实现
  vim.api.nvim_set_keymap("n", "gm", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  -- 跳转到引用位置
  vim.api.nvim_set_keymap("n", "gr", "<cmd>Lspsaga rename<CR>", opts)
  -- 以浮窗形式显示错误
  vim.api.nvim_set_keymap("n", "go", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  vim.api.nvim_set_keymap("n", "gp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  vim.api.nvim_set_keymap("n", "gn", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  vim.api.nvim_set_keymap("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
  vim.api.nvim_set_keymap("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
  vim.api.nvim_set_keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
  vim.api.nvim_set_keymap("v", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
end

local function git_keymaps()
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap("n", "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", opts)
end


local M = {}
M.setup = function ()
  lsp_keymaps()
  git_keymaps()
end

return M
