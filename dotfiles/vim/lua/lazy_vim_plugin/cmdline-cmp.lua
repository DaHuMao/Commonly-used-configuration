-- nvim-cmp 专门用于命令行补全
-- 与 blink.cmp 共存：blink 处理插入模式，cmp 处理命令行

return {
  {
    "hrsh7th/nvim-cmp",
    event = "CmdlineEnter",  -- 只在命令行模式加载
    dependencies = {
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      local cmp = require("cmp")

      -- 不设置插入模式的补全，让 blink.cmp 处理
      -- 只配置命令行补全

      -- 命令行 '/' 搜索补全
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- 命令行 '?' 搜索补全
      cmp.setup.cmdline('?', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- 命令行 ':' 命令补全
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          {
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' }
            }
          }
        })
      })
    end,
  },
}
