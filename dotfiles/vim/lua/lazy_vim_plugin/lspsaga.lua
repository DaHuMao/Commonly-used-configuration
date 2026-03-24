return {
  {
    'nvimdev/lspsaga.nvim',
    event = "LspAttach",
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require("lspsaga").setup({
        preview = {
          lines_above = 0,
          lines_below = 10,
        },
        scroll_preview = {
          scroll_down = "<C-n>",
          scroll_up = "<C-b>",
        },
        request_timeout = 2000,

        -- See Customizing Lspsaga's Appearance
        --ui = { ... },

        -- For default options for each command, see below
        finder = {
          max_height = 0.9,
          min_width = 30,
          left_width = 0.2,
          right_width = 0.9,
          force_max_height = false,
          keys = {
            shuttle = '[w',
            jump_to = 'p',
            expand_or_jump = 'e',
            toggle_or_open = 'o',
            vsplit = 's',
            split = 'i',
            tabe = 't',
            tabnew = 'r',
            quit = { 'q', '<ESC>' },
            close_in_preview = '<ESC>',
          },
        },
        code_action = {
          num_shortcut = true,
          show_server_name = false,
          extend_gitsigns = true,
          keys = {
            -- string | table type
            quit = "q",
            exec = "<CR>",
          },
        },
        -- etc.
      })
    end,
  }
}
