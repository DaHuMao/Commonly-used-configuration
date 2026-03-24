return {
  -- Useful lua functions used by lots of plugins
  { "nvim-lua/plenary.nvim" },

  -- icons
  { "nvim-tree/nvim-web-devicons" },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require("nvim-tree").setup {}
    end
  },

  -- vim-ansiesc 插件
  { 'powerman/vim-plugin-AnsiEsc', cmd = "AnsiEsc" },

  -- vsnip
  {
    'hrsh7th/vim-vsnip',
    event = "InsertEnter",
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
  },

  -- theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
  },

  {
    'norcalli/nvim-colorizer.lua',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('colorizer').setup({
        '*',
        css = { rgb_fn = true },
        html = { names = false },
      }, { RGB = true, RRGGBB = true, names = false, css = true, css_fn = true })
    end
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    ft = { "markdown" },
    config = function()
      require('render-markdown').setup()
    end
  },
-- install without yarn or npm
{
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
}
}
