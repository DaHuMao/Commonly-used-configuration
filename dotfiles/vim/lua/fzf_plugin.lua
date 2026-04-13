local M = {}

-- FZF 默认选项（纯 fzf 相关）
M.FZF_DEFAULT_OPTS = {
    '--ansi',
    '--layout=reverse',
    '--info=inline',
    '--bind', 'ctrl-/:toggle-preview',
    '--bind', 'ctrl-b:preview-half-page-up',
    '--bind', 'ctrl-n:preview-half-page-down',
}

-- 默认窗口配置
M.default_windows = { width = 0.9, height = 0.9 }

-- 创建浮动终端窗口
local function create_float_window(opts)
    opts = opts or {}
    local width = opts.width or 0.9
    local height = opts.height or 0.9

    local ui = vim.api.nvim_list_uis()[1]
    local win_width = math.floor(ui.width * width)
    local win_height = math.floor(ui.height * height)
    local row = math.floor((ui.height - win_height) / 2)
    local col = math.floor((ui.width - win_width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    return buf, win
end

-- 核心函数：fzf_run
-- source: 字符串（shell 命令）或者列表
-- sink: 选中后的回调函数
-- opts: 额外选项 { fzf_opts = {}, win_opts = {} }
function M.fzf_run(source, sink, opts)
    opts = opts or {}
    local fzf_opts = opts.fzf_opts or {}
    local win_opts = opts.win_opts or M.default_windows

    -- 构建 fzf 命令
    local fzf_cmd = 'fzf'

    -- 添加默认选项
    for _, opt in ipairs(M.FZF_DEFAULT_OPTS) do
        fzf_cmd = fzf_cmd .. ' ' .. vim.fn.shellescape(opt)
    end

    -- 添加额外选项
    for _, opt in ipairs(fzf_opts) do
        fzf_cmd = fzf_cmd .. ' ' .. vim.fn.shellescape(opt)
    end

    -- 构建完整命令
    local full_cmd = ''
    if type(source) == 'string' then
        -- source 是 shell 命令，用管道连接
        full_cmd = source .. ' | ' .. fzf_cmd
    elseif type(source) == 'table' then
        -- source 是列表，用 echo 输出
        local input = table.concat(source, '\n')
        full_cmd = 'echo ' .. vim.fn.shellescape(input) .. ' | ' .. fzf_cmd
    end

    -- 创建临时文件来存储选中结果
    local temp_file = vim.fn.tempname()
    full_cmd = full_cmd .. ' > ' .. vim.fn.shellescape(temp_file)

    -- 创建浮动窗口
    local buf, win = create_float_window(win_opts)

    -- 在终端中运行命令
    -- 注意：不要手动拼接 shell 和 -c，交给 Neovim 根据当前平台和 &shell/&shellcmdflag 处理
    -- 直接把整条命令字符串交给 termopen，这样在 macOS/Linux 会用 sh -c，在 Windows 会用正确的 shellcmdflag
    local job_id = vim.fn.termopen(full_cmd, {
        on_exit = function(_, exit_code, _)
            -- 关闭窗口
            vim.schedule(function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end

                -- 读取临时文件中的选中结果
                if exit_code == 0 then
                    local result = vim.fn.readfile(temp_file)
                    if #result > 0 then
                        local selected = result[1]
                        if sink and selected ~= '' then
                            sink(selected)
                        end
                    end
                end

                -- 删除临时文件
                vim.fn.delete(temp_file)
            end)
        end
    })

    -- 自动进入插入模式
    vim.cmd('startinsert')
end

return M
