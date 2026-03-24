-- LSP handlers 和 keymaps
local M = {}

M.setup = function()
  -- Diagnostic signs
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  -- Diagnostic config
  vim.diagnostic.config({
    virtual_text = false,
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })

  -- LSP handlers
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

-- Keymaps
M.on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set("n", "gd", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "<leader>t", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<A-cr>", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>dj", function()
    vim.diagnostic.goto_prev({ border = "rounded" })
  end, opts)
  vim.keymap.set("n", "<leader>dk", function()
    vim.diagnostic.goto_next({ border = "rounded" })
  end, opts)
  vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, opts)

  -- Load lsp_signature if available
  local status_ok, lsp_signature = pcall(require, "lsp_signature")
  if status_ok then
    lsp_signature.on_attach()
  end
end

-- Capabilities
M.capabilities = vim.lsp.protocol.make_client_capabilities()

-- 根据你使用的补全插件选择一个
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if status_ok then
  M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)
end

-- 如果使用 blink.cmp，取消上面的注释，使用下面的
-- local status_ok, blink = pcall(require, "blink.cmp")
-- if status_ok then
--   M.capabilities = blink.get_lsp_capabilities(M.capabilities)
-- end

return M
