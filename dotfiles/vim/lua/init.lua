require "plugin"
require "plug_config"
require("key_map").setup()
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
    "bashls",
    "jdtls",
    "clangd",
    "cmake",
    "pyright",
    "vimls",
	},
})
