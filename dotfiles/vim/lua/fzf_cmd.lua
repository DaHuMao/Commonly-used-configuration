local M = {}
local fzf_plugin = require('fzf_plugin')

-- RG 相关常量配置（放在这里，因为与 fzf 无关）
M.RG_DEFAULT_CONFIG = "rg --column --line-number --no-heading --color=always --max-columns 250 --max-filesize 500K"
M.default_preview = 'bat --color=always --theme=gruvbox-dark {1} --highlight-line {2}'

-- 编辑文件的函数
function M.edit_file(file_name)
    vim.notify('edit file: ' .. file_name, vim.log.levels.INFO)
    vim.cmd('silent e ' .. file_name)
end

-- 编辑 rg 搜索结果的函数
function M.edit_rg_file(strr)
    local arr = vim.split(strr, ':')
    local index = 1
    if vim.fn.filereadable(arr[1]) == 1 then
        vim.cmd('silent e ' .. arr[1])
        index = 2
    end
    if arr[index] then
        vim.cmd('normal! ' .. arr[index] .. 'G')
    end
    if arr[index + 1] then
        vim.cmd('normal! ^' .. arr[index + 1] .. 'l')
    end
end

-- 针对 rg 的 fzf 封装
function M.fzf_for_rg(source, edit_fun, preview_script)
    local preview_script_str = M.default_preview
    if preview_script and preview_script ~= '' then
        preview_script_str = preview_script
    end

    local fzf_opts = {
        '--delimiter', ':',
        '--preview', preview_script_str,
        '--preview-window', 'up,70%,border-bottom,hidden,wrap,+{2}+3/3,~3',
    }

    fzf_plugin.fzf_run(source, edit_fun or M.edit_rg_file, { fzf_opts = fzf_opts })
end

-- RipgrepFzf 实现
function M.RipgrepFzf(query, file_suffix, exclude_cmd)
    local str = "--smart-case -e ''"
    if query and query ~= '' then
        str = ' -F -- ' .. query
    end

    local initial_command
    if file_suffix and file_suffix ~= '' then
        initial_command = string.format(
            M.RG_DEFAULT_CONFIG .. ' -g "*.{%s}" %s %s',
            file_suffix,
            exclude_cmd or '',
            str
        )
    else
        initial_command = string.format(
            M.RG_DEFAULT_CONFIG .. ' %s %s',
            exclude_cmd or '',
            str
        )
    end
    vim.notify('initial_command: ' .. initial_command, vim.log.levels.INFO)
    M.fzf_for_rg(initial_command, M.edit_rg_file)
end

function M.RipgrepFzfAll(...)
    local args = {...}
    local command_fmt = M.RG_DEFAULT_CONFIG

    if args[1] == 0 then
        command_fmt = 'rg --column --line-number --no-heading --color=always --no-ignore-vcs --max-columns 250 --max-filesize 250K'
    end

    local is_regexp = ' -F '
    if #args > 1 and args[2] ~= '' then
        is_regexp = ' -e '
    end

    if #args > 3 and args[4] ~= '0' then
        command_fmt = command_fmt .. " -g '*.{" .. args[4] .. "}'"
    end

    if #args > 4 and args[5] ~= '0' then
        command_fmt = command_fmt .. " -g  '!*.{" .. args[5] .. "}'"
    end

    if #args > 6 then
        command_fmt = command_fmt .. ' ' .. args[6]
    end

    if #args > 2 then
        command_fmt = command_fmt .. is_regexp .. "-- " .. args[3]
    else
        command_fmt = command_fmt .. " --smart-case " .. is_regexp .. " ''"
    end

    M.fzf_for_rg(command_fmt, M.edit_rg_file)
end

function M.RipgrepFzfFunction(func_name, enable_smart_case)
    local smart_case = ''
    if enable_smart_case > 0 then
        smart_case = ' --smart-case '
    end

    local str1 = '^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\\*?  *' .. func_name .. '\\('
    local str2 = '^ *' .. func_name .. '\\('
    local command_fmt = M.RG_DEFAULT_CONFIG .. smart_case .. ' -g "*.{h}" -e "%s|%s"'
    local initial_command = string.format(command_fmt, str1, str2)

    M.fzf_for_rg(initial_command, M.edit_rg_file)
end

function M.RipgrepFzfClassDefine(class_name, enable_smart_case)
    local smart_case = ''
    if enable_smart_case > 0 then
        smart_case = ' --smart-case '
    end

    local str1 = "#define *" .. class_name
    local str2 = "using *" .. class_name .. ' *='
    local str3 = "class .*" .. class_name .. ' '
    local str4 = "struct .*" .. class_name .. ' '
    local str5 = "enum *" .. class_name .. ' '
    local str6 = "typedef .* " .. class_name .. ' *;'
    local gstr1 = "class .*" .. class_name .. ' *;'
    local gstr2 = "struct .*" .. class_name .. ' *;'

    local command_fmt = M.RG_DEFAULT_CONFIG .. smart_case .. ' -g "*.{h}" -e "%s|%s|%s|%s|%s|%s" | rg -v "%s|%s"'
    local initial_command = string.format(command_fmt, str1, str2, str3, str4, str5, str6, gstr1, gstr2)

    M.fzf_for_rg(initial_command, M.edit_rg_file)
end

function M.RipgrepFzfValDefine(val_name, enable_smart_case)
    local smart_case = ''
    if enable_smart_case > 0 then
        smart_case = ' --smart-case '
    end

    local str1 = '^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\\*?  *' .. val_name .. ' *;'
    local str2 = '^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\\*?  *' .. val_name .. ' *='
    local str3 = '^ *(const |constexpr )? *[a-zA-Z0-9_]+((::[a-zA-Z0-9_]+)?(<.*>)?)*\\*?  *' .. val_name .. ' .*;'

    local command_fmt = M.RG_DEFAULT_CONFIG .. smart_case .. ' -g "*.{h,cpp,cc,c,m,mm,java}" -e "%s|%s|%s"'
    local initial_command = string.format(command_fmt, str1, str2, str3)

    M.fzf_for_rg(initial_command, M.edit_rg_file)
end

function M.RipgrepFzfFunctionRef(func_name, enable_smart_case)
    local smart_case = ''
    if enable_smart_case > 0 then
        smart_case = ' --smart-case '
    end

    local str1 = ' *[a-zA-Z0-9_]+::' .. func_name .. '\\('
    local str2 = '^ *[a-zA-Z0-9_]+  *' .. func_name .. '.*\\{'

    local command_fmt = M.RG_DEFAULT_CONFIG .. smart_case .. ' -g "*.{cpp,cc,c}" -e "%s|%s"'
    local initial_command = string.format(command_fmt, str1, str2)

    M.fzf_for_rg(initial_command, M.edit_rg_file)
end

function M.FindFile(file_path, is_all)
    local path = file_path or '.'
    if path == '' then
        path = '.'
    end

    local command_fmt = 'fd --type f --hidden --follow --exclude .o --exclude .git '
    if is_all and is_all > 0 then
        command_fmt = command_fmt .. '--no-ignore'
    end
    command_fmt = command_fmt .. ' . ' .. path

    M.fzf_for_rg(command_fmt, M.edit_file, 'bat --color=always --theme=gruvbox-dark {}')
end

function M.FindWordInCurBuffer(str)
    local cur_file = vim.api.nvim_buf_get_name(0)
    if vim.fn.has('win32') == 1 then
        cur_file = cur_file:gsub('\\', '/')
    end

    local command_fmt = M.RG_DEFAULT_CONFIG .. " --no-filename -- " .. str .. ' ' .. cur_file
    local preview_script_str = 'bat --color=always --theme=gruvbox-dark ' .. cur_file .. ' --highlight-line {1}'

    local fzf_opts = {
        '--delimiter', ':',
        '--preview', preview_script_str,
        '--preview-window', 'up,70%,border-bottom,hidden,wrap,+{1}+3/3,~3',
    }

    fzf_plugin.fzf_run(command_fmt, M.edit_rg_file, { fzf_opts = fzf_opts })
end

-- 命令注册
function M.setup()
    -- 从原 fzf.vim 移植的所有命令

    -- Rfile: 查找文件
    vim.api.nvim_create_user_command('Rfile', function(opts)
        M.FindFile(opts.args, 0)
    end, { nargs = 1, complete = 'dir' })

    -- Rfa: 查找所有文件（包括 ignore 的）
    vim.api.nvim_create_user_command('Rfa', function(opts)
        M.FindFile(opts.args ~= '' and opts.args or nil, 1)
    end, { nargs = '?', complete = 'dir' })

    -- Rbufferc: 在当前缓冲区查找当前单词
    vim.api.nvim_create_user_command('Rbufferc', function()
        M.FindWordInCurBuffer(vim.fn.expand('<cword>'))
    end, {})

    -- Rbuffer: 在当前缓冲区查找所有内容
    vim.api.nvim_create_user_command('Rbuffer', function()
        M.FindWordInCurBuffer('.')
    end, {})

    -- Rf: 查找函数定义
    vim.api.nvim_create_user_command('Rf', function(opts)
        M.RipgrepFzfFunction(opts.args, 1)
    end, { nargs = 1 })

    -- Rfc: 查找当前单词的函数定义
    vim.api.nvim_create_user_command('Rfc', function()
        M.RipgrepFzfFunction(vim.fn.expand('<cword>'), 0)
    end, {})

    -- Ri: 查找函数引用
    vim.api.nvim_create_user_command('Ri', function(opts)
        M.RipgrepFzfFunctionRef(opts.args, 1)
    end, { nargs = 1 })

    -- Ric: 查找当前单词的函数引用
    vim.api.nvim_create_user_command('Ric', function()
        M.RipgrepFzfFunctionRef(vim.fn.expand('<cword>'), 0)
    end, {})

    -- Rc: 查找类定义
    vim.api.nvim_create_user_command('Rc', function(opts)
        M.RipgrepFzfClassDefine(opts.args, 1)
    end, { nargs = 1 })

    -- Rcc: 查找当前单词的类定义
    vim.api.nvim_create_user_command('Rcc', function()
        M.RipgrepFzfClassDefine(vim.fn.expand('<cword>'), 0)
    end, {})

    -- Rv: 查找变量定义
    vim.api.nvim_create_user_command('Rv', function(opts)
        M.RipgrepFzfValDefine(opts.args, 1)
    end, { nargs = 1 })

    -- Rvc: 查找当前单词的变量定义
    vim.api.nvim_create_user_command('Rvc', function()
        M.RipgrepFzfValDefine(vim.fn.expand('<cword>'), 0)
    end, {})

    -- Rgc: 使用内置 Rg 命令查找当前单词
    vim.api.nvim_create_user_command('Rgc', function()
        vim.cmd('Rg ' .. vim.fn.expand('<cword>'))
    end, { nargs = '*' })

    -- Raa: 高级搜索
    vim.api.nvim_create_user_command('Raa', function(opts)
        M.RipgrepFzfAll(0, '', opts.args)
    end, { nargs = '*' })

    -- Ra: 搜索所有文件（--no-ignore-vcs）
    vim.api.nvim_create_user_command('Ra', function(opts)
        M.RipgrepFzf(opts.args, '', '--no-ignore-vcs')
    end, { nargs = '?', complete = 'dir' })

    -- Rac: 搜索当前单词（--no-ignore）
    vim.api.nvim_create_user_command('Rac', function()
        M.RipgrepFzf(vim.fn.expand('<cword>'), '', '--no-ignore')
    end, {})

    -- Raac: 搜索当前单词（--no-ignore）
    vim.api.nvim_create_user_command('Raac', function()
        M.RipgrepFzf(vim.fn.expand('<cword>'), '', '--no-ignore ')
    end, {})

    -- RG: 在指定文件类型中搜索，排除 unittest
    vim.api.nvim_create_user_command('RG', function(opts)
        local file_suffix = 'h,hpp,cpp,cc,c,m,mm,java,ets'
        local exclude_cmd = '-g !"*unittest*" '
        M.RipgrepFzf(opts.args, file_suffix, exclude_cmd)
    end, { nargs = '?', complete = 'dir' })

    -- RGc: 在指定文件类型中搜索当前单词，排除 unittest
    vim.api.nvim_create_user_command('RGc', function()
        local file_suffix = 'h,hpp,cpp,cc,c,m,mm,java,ets'
        local exclude_cmd = '-g !"*unittest*" '
        M.RipgrepFzf(vim.fn.expand('<cword>'), file_suffix, exclude_cmd)
    end, {})

    -- Rgn: 在 gn 文件中搜索
    vim.api.nvim_create_user_command('Rgn', function(opts)
        M.RipgrepFzf(opts.args, "gn,gni", "")
    end, { nargs = '?', complete = 'dir' })

    -- Rgnc: 在 gn 文件中搜索当前单词
    vim.api.nvim_create_user_command('Rgnc', function()
        M.RipgrepFzf(vim.fn.expand('<cword>'), "gn,gni", "")
    end, {})

    -- Rpy: 在 Python 文件中搜索
    vim.api.nvim_create_user_command('Rpy', function(opts)
        M.RipgrepFzf(opts.args, "py", "")
    end, { nargs = '?', complete = 'dir' })

    -- Rpyc: 在 Python 文件中搜索当前单词
    vim.api.nvim_create_user_command('Rpyc', function()
        M.RipgrepFzf(vim.fn.expand('<cword>'), "py", "")
    end, {})

    -- Rja: 在 Java 文件中搜索
    vim.api.nvim_create_user_command('Rja', function(opts)
        M.RipgrepFzf(opts.args, "java", "")
    end, { nargs = '?', complete = 'dir' })

    -- Rjac: 在 Java 文件中搜索当前单词
    vim.api.nvim_create_user_command('Rjac', function()
        M.RipgrepFzf(vim.fn.expand('<cword>'), "java", "")
    end, {})

    -- Rsh: 在 Shell 文件中搜索
    vim.api.nvim_create_user_command('Rsh', function(opts)
        M.RipgrepFzf(opts.args, "sh,bash,zsh", "")
    end, { nargs = '?', complete = 'dir' })

    -- Rshc: 在 Shell 文件中搜索当前单词
    vim.api.nvim_create_user_command('Rshc', function()
        M.RipgrepFzf(vim.fn.expand('<cword>'), "sh", "")
    end, {})

    -- Rcm: 在 CMake/Makefile 文件中搜索
    vim.api.nvim_create_user_command('Rcm', function(opts)
        local exclude_cmd = '-g "*.cmake" -g "CMakeLists.txt" -g "Makefile"'
        M.RipgrepFzf(opts.args, "", exclude_cmd)
    end, { nargs = '?', complete = 'dir' })

    -- Rcmc: 在 CMake/Makefile 文件中搜索当前单词
    vim.api.nvim_create_user_command('Rcmc', function()
        local exclude_cmd = '-g "*.cmake" -g "CMakeLists.txt" -g "Makefile"'
        M.RipgrepFzf(vim.fn.expand('<cword>'), "", exclude_cmd)
    end, {})


end

return M
