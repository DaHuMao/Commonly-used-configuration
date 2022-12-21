
local opts = { noremap = true, silent = true }
--local keymap=vim.api.nvim_set_keymap
local keymap = vim.keymap.set
local function lsp_keymaps()
  -- 跳转到声明
  keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
  -- 跳转到定义
  keymap("n", "gi", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  -- 显示注释文档
  keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", opts)
  -- 跳转到实现
  keymap("n", "gm", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  -- 跳转到引用位置
  keymap("n", "gr", "<cmd>Lspsaga rename<CR>", opts)
  -- 以浮窗形式显示错误
  keymap("n", "go", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  keymap("n", "gp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  keymap("n", "gn", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  keymap("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
  keymap("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
  keymap({"n", "v"}, "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
end

local function git_keymaps()
  keymap("n", "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", opts)
end

local function debug_keymaps()
  keymap("n", "<A-b>", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts)
  -- keymap("n", "<leader>dB", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input '[Condition] > ')<cr>", opts)
  -- keymap("n", "<leader>dr", "lua require'dap'.repl.open()<cr>", opts)
  -- keymap("n", "<F9>", "<cmd>lua require'dap'.run_last()<cr>", opts)
  keymap('n', '<F10>', '<cmd>lua require"plug_config.dap.dap-util".reload_continue()<CR>', opts)
  keymap("n", "<A-t>", "<cmd>lua require'dap'.terminate()<cr>", opts)
  keymap("n", "<F5>", "<cmd>lua require'dap'.continue()<cr>", opts)
  keymap("n", "<F6>", "<cmd>lua require'dap'.step_over()<cr>", opts)
  keymap("n", "<F7>", "<cmd>lua require'dap'.step_into()<cr>", opts)
  keymap("n", "<F8>", "<cmd>lua require'dap'.step_out()<cr>", opts)
  keymap("n", "Z", "<cmd>lua require'dapui'.eval()<cr>", opts)
end
local M = {}
M.setup = function ()
  lsp_keymaps()
  git_keymaps()
  debug_keymaps()
end

return M
