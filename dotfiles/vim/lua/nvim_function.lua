
local M = {}

M.name_num = 0

-- 驼峰转下划线（支持自定义分隔符）
function M.camel_to_snake(str, separator)
  separator = separator or '_'
  return str:gsub('(%u)', function(c)
    return separator .. c:lower()
  end):gsub('^'..separator, '')
end

-- 下划线转驼峰（支持自定义分隔符）
function M.snake_to_camel(str, separator)
  separator = separator or '_'
  return str:gsub(separator..'(%a)', function(c)
    return c:upper()
  end):gsub('^%l', string.upper)
end

-- 选择并链接 compile_commands.json 文件
function M.select_compile(opts)
  local search_dir = opts.args ~= '' and opts.args or '.'
  local cmd_base

  -- 根据是否指定目录，构建不同的搜索命令
  if opts.args ~= '' then
    -- 用户指定了目录，直接在该目录下搜索
    cmd_base = string.format("fd --no-ignore compile_commands.json '%s'", search_dir)
  else
    -- 未指定目录，先找 build* 或 out* 目录，再在这些目录下搜索
    cmd_base = "fd --no-ignore -t d '^(build|out)' . -x fd --no-ignore compile_commands.json {}"
  end

  -- 执行搜索命令获取文件列表
  local handle = io.popen(cmd_base)
  if not handle then
    vim.notify("Failed to search for compile_commands.json", vim.log.levels.ERROR)
    return
  end

  local files_str = handle:read("*a")
  handle:close()

  -- 解析结果
  local files = {}
  for file in files_str:gmatch("[^\n]+") do
    if file ~= "" then
      table.insert(files, file)
    end
  end

  if #files == 0 then
    vim.notify("No compile_commands.json found", vim.log.levels.WARN)
    return
  end

  -- 内部函数：创建软链接并重启 LSP
  local function create_compile_symlink(selected_file)
    local current_dir = vim.fn.getcwd()
    local link_path = current_dir .. "/compile_commands.json"

    -- 移除旧的链接/文件（如果存在）
    os.execute(string.format("rm -f '%s'", link_path))

    -- 创建软链接
    local ln_cmd = string.format("ln -s '%s' '%s'", selected_file, link_path)
    local ln_status = os.execute(ln_cmd)

    if ln_status == 0 then
      vim.notify(string.format("Created symlink: %s -> %s", link_path, selected_file), vim.log.levels.INFO)
      -- 执行 :LspStop 和 :LspRestart
      vim.api.nvim_command("LspStop")
      vim.defer_fn(function()
        vim.api.nvim_command("LspRestart")
      end, 100)
    else
      vim.notify("Failed to create symlink", vim.log.levels.ERROR)
    end
  end

  -- 使用 vim fzf 插件让用户选择
  local fzf_opts = {
    source = files,
    sink = function(selected)
      create_compile_symlink(selected)
    end,
  }

  vim.fn['fzf#run'](vim.fn['fzf#wrap'](fzf_opts))
end

-- 打开窗口并执行命令
function M.open_window_with_cmd(cmd, size, window_name)
  local windows_manager = require('windows_manager')
  if window_name == nil then
    window_name = 'window'
  end
  M.name_num = M.name_num + 1
  window_name = window_name .. M.name_num
  size = size or 'm'
  windows_manager.create_window(window_name, size, true, cmd)
end

-- 注册Vim命令
local function setup_commands()
  vim.api.nvim_create_user_command('CtoS', function(opts)
    local separator = opts.args ~= '' and opts.args or '_'
    local word = vim.fn.expand('<cword>')
    local converted = M.camel_to_snake(word, separator)
    vim.api.nvim_command('normal! ciw'..converted)
  end, { nargs = '?', complete = function() return { '_', '-', '.' } end })

  vim.api.nvim_create_user_command('StoC', function(opts)
    local separator = opts.args ~= '' and opts.args or '_'
    local word = vim.fn.expand('<cword>')
    local converted = M.snake_to_camel(word, separator)
    vim.api.nvim_command('normal! ciw'..converted)
  end, { nargs = '?', complete = function() return { '_', '-', '.' } end })

  vim.api.nvim_create_user_command('SelectCompile', function(opts)
    M.select_compile(opts)
  end, { nargs = '?' })

  vim.api.nvim_create_user_command('ClaudeOpen', function(opts)
    local window_name = 'claude_' .. opts.args
    M.open_window_with_cmd('source $HOME/.myzsh/claude.sh', 'm', window_name)
  end, {
    nargs = '?',
    desc = 'Open a new Claude terminal window',
  })

  vim.api.nvim_create_user_command('Coco', function(opts)
    local window_name =   'coco_' .. opts.args
    M.open_window_with_cmd('coco', 'm', window_name)
  end, {
    nargs = '?',
    desc = 'Open a new Claude terminal window',
  })
end

-- 初始化
function M.setup()
  setup_commands()
end

return M
