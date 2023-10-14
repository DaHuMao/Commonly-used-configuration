local log_filename = os.getenv("HOME") .. "/.local/state/nvim/lsp.log"
local log_file = io.open(log_filename, "r")
if log_file then
    local size = log_file:seek("end")
    log_file:close()
    if size > 1048576 then
      log_file = io.open(log_filename, "w")
      if log_file then
        log_file:close()
      end
    end
end
local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  print("error: can not find lspconfig")
	return
end

require "plug_config.lsp.settings"
require'lspconfig'.clangd.setup{}
