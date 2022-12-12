local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  print("error: can not find lspconfig")
	return
end

require "plug_config.lsp.settings"
require'lspconfig'.clangd.setup{}
