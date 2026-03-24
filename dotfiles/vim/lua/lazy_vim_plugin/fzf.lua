return {
  {
    'junegunn/fzf',
    build = './install --bin',
    lazy = false,  -- 立即加载，不懒加载
    priority = 1000,  -- 高优先级加载
  },
  {
    'junegunn/fzf.vim',
    dependencies = { 'junegunn/fzf' },
    lazy = false,  -- 立即加载，避免快捷键延迟
    priority = 999,
    config = function()
      -- FZF 配置选项
      vim.g.fzf_preview_window = { 'right:50%', 'ctrl-/' }
      vim.g.fzf_layout = { window = { width = 0.9, height = 0.8 } }

      -- 自定义 FZF 颜色以匹配 neovim 主题
      vim.g.fzf_colors = {
        fg      = {'fg', 'Normal'},
        bg      = {'bg', 'Normal'},
        hl      = {'fg', 'Comment'},
        ['fg+'] = {'fg', 'CursorLine', 'CursorColumn', 'Normal'},
        ['bg+'] = {'bg', 'CursorLine', 'CursorColumn'},
        ['hl+'] = {'fg', 'Statement'},
        info    = {'fg', 'PreProc'},
        border  = {'fg', 'Ignore'},
        prompt  = {'fg', 'Conditional'},
        pointer = {'fg', 'Exception'},
        marker  = {'fg', 'Keyword'},
        spinner = {'fg', 'Label'},
        header  = {'fg', 'Comment'}
      }
    end,
  }
}
