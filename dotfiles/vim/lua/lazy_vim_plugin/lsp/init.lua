-- LSP 基础配置和 handlers
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",   -- 如果使用 blink.cmp
    },
    config = function()
      -- 加载 handlers 配置
      require("lazy_vim_plugin.lsp.handlers").setup()

      -- 加载各语言服务器配置
      require("lazy_vim_plugin.lsp.servers")
    end,
  },

  -- LSP Signature
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      handler_opts = {
        border = "rounded"
      },
      hint_enable = false,
    },
  },

  -- Mason (LSP 服务器管理)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    build = ":MasonUpdate",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      automatic_installation = true,
      ensure_installed = {
        "lua_ls",
        "bashls",
        "jdtls",
        "clangd",
        "cmake",
        "pyright",
        "vimls",
      },
    },
  },
}
