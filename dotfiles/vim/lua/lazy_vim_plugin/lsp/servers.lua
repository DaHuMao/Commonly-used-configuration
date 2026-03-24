-- 各语言服务器配置
-- LSP 会根据文件类型自动启动对应的服务器

local handlers = require("lazy_vim_plugin.lsp.handlers")
local util = require("util")

-- 检查 LSP 日志文件大小，超过 100K 则清理
local function check_lsp_logs()
  local log_file = vim.fn.stdpath("state") .. "/nvim/lsp.log"
  local max_size = 100 * 1024  -- 100K
  util.check_log_size(log_file, max_size, 0)
end

check_lsp_logs()

local servers = {
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = {'vim'},
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
          typeCheckingMode = "off"
        },
      },
    },
  },
  bashls = {
    cmd = { "bash-language-server", "start" },
    filetypes = { "bash", "sh" },
  },
  clangd = {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "cc", "cxx" },
  },
  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },
  vimls = {
    cmd = { "vim-language-server", "--stdio" },
    filetypes = { "vim" },
  },
}

-- 配置所有服务器
for server_name, config in pairs(servers) do
  config.on_attach = handlers.on_attach
  config.capabilities = handlers.capabilities
  config.autostart = true
  vim.lsp.config(server_name, config)
end
