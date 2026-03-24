-- blink.cmp 补全配置
-- 注意：nvim-cmp 和 blink.cmp 只能选择一个！
-- 如果使用 blink.cmp，请注释掉 cmp.lua 文件

return {
  {
    "saghen/blink.cmp",
    -- version = "v0.*",  -- 使用预编译的发布版本
    build = "cargo build --release", -- 本地编译（需要 Rust）
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    event = "InsertEnter",  -- 只在插入模式加载，不包括 CmdlineEnter
    opts = {
      keymap = {
        preset = 'default',
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'hide', 'fallback' },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      completion = {
        menu = {
          border = 'rounded',
          auto_show = true,  -- 自动显示补全菜单
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = {
            border = 'rounded',
          },
        },
        trigger = {
          show_on_insert_on_trigger_character = true,
        },
      },

      -- 禁用 cmdline 补全（目前 blink.cmp 的 cmdline 还有问题）
      cmdline = {
        enabled = false,
      },
    },
  }
}
