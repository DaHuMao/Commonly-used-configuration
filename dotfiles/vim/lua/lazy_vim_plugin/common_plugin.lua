local MAX_LOG_HIGHLIGHT_FILE_SIZE = 5 * 1024 * 1024

local function should_use_log_filetype(path)
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= "file" then
    return true
  end

  return stat.size <= MAX_LOG_HIGHLIGHT_FILE_SIZE
end

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
    'fei6409/log-highlight.nvim',
    ft = { "log" },
    init = function()
      vim.filetype.add({
        extension = {
          log = function(path)
            if should_use_log_filetype(path) then
              return "log"
            end

            return "text"
          end,
        },
      })
    end,
    opts = {},
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
