-- Use platform detection functions from env.vim
local function is_windows()
    return vim.fn.IsWindows() == 1
end

local function is_macos()
    return vim.fn.IsMacos() == 1
end

local function is_linux()
    return vim.fn.IsLinux() == 1
end

-- Get path separator based on platform
local function get_path_separator()
    if is_windows() then
        return ';'
    else
        return ':'
    end
end

-- Extract directory path from file path (handles both Unix and Windows paths)
local function get_dir_from_path(file_path)
    -- Try Windows path first (with backslash)
    local dir_path = file_path:match("(.*)\\[^\\]*$")
    if dir_path then
        return dir_path .. "\\"
    end
    -- Try Unix path (with forward slash)
    dir_path = file_path:match("(.*)/[^/]*$")
    if dir_path then
        return dir_path .. "/"
    end
    return nil
end

-- 初始化 VIM_USED_NODE_BIN 环境变量
local node_bin_env = vim.env.VIM_USED_NODE_BIN

-- 如果 VIM_USED_NODE_BIN 被定义
if node_bin_env and node_bin_env ~= "" then
    -- 提取目录路径（假设 node 可执行文件在该目录下）
    local node_bin_path = get_dir_from_path(node_bin_env)
    if node_bin_path then
        vim.notify("Using Node.js from: " .. node_bin_path)
        -- 更新 vim.env.PATH，使用平台相关的分隔符
        local path_separator = get_path_separator()
        vim.env.PATH = node_bin_path .. path_separator .. vim.env.PATH
    end
end
