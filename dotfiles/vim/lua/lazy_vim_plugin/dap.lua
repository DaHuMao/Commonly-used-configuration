return {
  -- DAP core plugin
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
    },
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle breakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Continue' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'Step into' },
      { '<leader>do', function() require('dap').step_over() end, desc = 'Step over' },
      { '<leader>dO', function() require('dap').step_out() end, desc = 'Step out' },
      { '<leader>dr', function() require('dap').repl.open() end, desc = 'Open REPL' },
      { '<leader>dl', function() require('dap').run_last() end, desc = 'Run last' },
      { '<leader>dt', function() require('dapui').toggle() end, desc = 'Toggle DAP UI' },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      -- Configure DAP signs
      vim.fn.sign_define("DapBreakpoint", {
        text = "🛑",
        texthl = "LspDiagnosticsSignError",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "⭐️",
        texthl = "LspDiagnosticsSignInformation",
        linehl = "DiagnosticUnderlineInfo",
        numhl = "LspDiagnosticsSignInformation",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "",
        texthl = "LspDiagnosticsSignHint",
        linehl = "",
        numhl = "",
      })

      -- Configure DAP UI
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = ">"},
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        element_mappings = {},
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "stacks", size = 0.35 },
              { id = "watches", size = 0.15 },
              { id = "breakpoints", size = 0.15 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        }
      })

      -- Configure DAP virtual text
      require("nvim-dap-virtual-text").setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        show_stop_reason = true,
        commented = false,
        virt_text_pos = 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
      }

      -- Auto open/close DAP UI
      local debug_open = function()
        dapui.open()
        vim.api.nvim_command("DapVirtualTextEnable")
      end
      local debug_close = function()
        dap.repl.close()
        dapui.close()
        vim.api.nvim_command("DapVirtualTextDisable")
      end

      dap.listeners.after.event_initialized["dapui_config"] = function()
        debug_open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        debug_close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        debug_close()
      end
      dap.listeners.before.disconnect["dapui_config"] = function()
        debug_close()
      end

      -- Set log level and terminal config
      dap.defaults.fallback.terminal_win_cmd = '30vsplit new'
      dap.set_log_level("DEBUG")

      -- Load language configurations
      local dap_config_path = vim.fn.stdpath("config") .. "/lua/lazy_vim_plugin/dap"
      package.path = package.path .. ";" .. dap_config_path .. "/?.lua"

      -- Python configuration
      dap.adapters.python = {
        type = "executable",
        command = "/usr/bin/python3",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "launch file",
          program = "${file}",
          pythonPath = function()
            local venv_path = os.getenv("VIRTUAL_ENV")
            if venv_path then
              return venv_path .. "/bin/python"
            end
            return "/usr/bin/python3"
          end
        }
      }

      -- C/C++/Rust configuration (codelldb)
      local cmd = vim.fn.stdpath "data" .. "/mason/bin/codelldb"
      if vim.fn.filereadable(cmd) == 1 then
        dap.adapters.codelldb = function(on_adapter)
          local tcp = vim.loop.new_tcp()
          tcp:bind("127.0.0.1", 0)
          local port = tcp:getsockname().port
          tcp:shutdown()
          tcp:close()

          local stdout = vim.loop.new_pipe(false)
          local stderr = vim.loop.new_pipe(false)
          local opts = {
            stdio = {nil, stdout, stderr},
            args = {"--port", tostring(port)}
          }
          local handle
          local pid_or_err
          handle, pid_or_err = vim.loop.spawn(
            cmd,
            opts,
            function(code)
              stdout:close()
              stderr:close()
              handle:close()
              if code ~= 0 then
                print("codelldb exited with code", code)
              end
            end
          )
          if not handle then
            vim.notify("Error running codelldb: " .. tostring(pid_or_err), vim.log.levels.ERROR)
            stdout:close()
            stderr:close()
            return
          end
          vim.notify("codelldb started. pid=" .. pid_or_err)
          stderr:read_start(
            function(err, chunk)
              assert(not err, err)
              if chunk then
                vim.schedule(
                  function()
                    require("dap.repl").append(chunk)
                  end
                )
              end
            end
          )
          local adapter = {
            type = "server",
            host = "127.0.0.1",
            port = port
          }
          vim.defer_fn(
            function()
              on_adapter(adapter)
            end,
            500
          )
        end

        dap.configurations.cpp = {
          {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            pid = function()
              local handle = io.popen("pgrep hw$")
              local result = handle:read()
              handle:close()
              return result
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = true
          }
        }

        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp
      end

      -- Lua configuration (nlua)
      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = "Attach to running Neovim instance",
          cwd = '${workspaceFolder}',
          host = function()
            local value = vim.fn.input('Host [127.0.0.1]: ')
            if value ~= "" then
              return value
            end
            return '127.0.0.1'
          end,
          port = function()
            local val = tonumber(vim.fn.input('Port: '))
            assert(val, "Please provide a port number")
            return val
          end,
        }
      }

      dap.adapters.nlua = function(callback, config)
        callback({ type = 'server', host = config.host, port = config.port })
      end

      -- Load from json file
      require('dap.ext.vscode').load_launchjs(nil, { cppdbg = { 'cpp' } })
    end,
  }
}
