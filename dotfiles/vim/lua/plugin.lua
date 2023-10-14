local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- My plugins here
  use "wbthomason/packer.nvim" -- Have packer manage itself
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins

  --  replace words
  use 'nvim-pack/nvim-spectre'

  --git
  use "lewis6991/gitsigns.nvim"
  use "kyazdani42/nvim-web-devicons" -- icons
  -- Packer
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

  --dap
  use "theHamsta/nvim-dap-virtual-text"
  use {'mfussenegger/nvim-dap'}
  use "rcarriga/nvim-dap-ui"

  use "nvim-treesitter/nvim-treesitter"
  --use "williamboman/nvim-lsp-installer" -- simple to use language server installer
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
}
  --cmp
  use "hrsh7th/nvim-cmp" -- The completion plugin
  use "hrsh7th/cmp-buffer" -- buffer completions
  use "hrsh7th/cmp-path" -- path completions
  use "hrsh7th/cmp-cmdline" -- cmdline completions
  use "saadparwaiz1/cmp_luasnip" -- snippet completions
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-nvim-lua"
  -- vsnip
  use {'hrsh7th/vim-vsnip'}
  use {'rafamadriz/friendly-snippets'}
  -- lspkind
  use {'onsails/lspkind-nvim'}

  -- java
  use 'mfussenegger/nvim-jdtls'

  -- lspsaga
  use({
    "glepnir/lspsaga.nvim",
    opt = false,
    branch = "main",
    event = "LspAttach",
    requires = {
        {"nvim-tree/nvim-web-devicons"},
        --Please make sure you install markdown and markdown_inline parser
        {"nvim-treesitter/nvim-treesitter"}
    }
  })



  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
