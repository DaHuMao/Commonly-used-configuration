return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    requires = {
      "copilotlsp-nvim/copilot-lsp",
      init = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
    config = function()
      -- 设置代理端口
      --vim.g.copilot_proxy = '127.0.0.1:7891'

      -- 如果环境变量中有指定的Node路径，则使用该路径
      local node_bin = vim.env.VIM_USED_NODE_BIN
      if node_bin and node_bin ~= "" then
        -- 检查可执行性的逻辑需要在Lua中实现
        -- 这里假设CheckExecutable函数在Vim中可用
        vim.cmd('call CheckExecutable("' .. node_bin .. '")')
        vim.g.copilot_node_command = node_bin
      end

      -- 配置Copilot
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-d>",  -- 对应vim中的 <C-d> 接受建议
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
        filetypes = {
          -- 可以在这里添加或排除特定文件类型
          -- ["*"] = true,  -- 启用所有文件类型
        },
      })

      -- 禁用Tab映射，对应vim中的 g:copilot_no_tab_map = v:true
      vim.g.copilot_no_tab_map = true
    end,
  },
}
