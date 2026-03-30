local M = {}

-- Window operation step size (as fraction of screen size)
M.RESIZE_STEP = 0.05    -- Step size for resizing window (5% of screen)
M.MOVE_STEP = 0.05       -- Step size for moving window (10% of screen)
M.VERTICAL_OFFSET = -0.025 -- Vertical offset for window center (positive = up, negative = down, as fraction of screen height)

-- Window state management
M.state = {
    foreground_windows = {}, -- Foreground window array
    background_windows = {}, -- Background window array
    window_counter = 0,      -- Window counter
    fzf_window = nil,        -- Track FZF window ID for toggle functionality
    fzf_action = nil,        -- Track current FZF action type ('show' or 'delete')
}

-- Window size configuration
M.size_config = {
    l = { width = 0.95, height = 0.90 }, -- Large window
    m = { width = 0.7, height = 0.7 }, -- Medium window
    x = { width = 0.4, height = 0.4 }, -- Small window
}

-- Get window size based on screen size
local function get_window_size(size_type)
    size_type = size_type or 'm' -- Default to medium size
    local config = M.size_config[size_type] or M.size_config.m

    local ui = vim.api.nvim_list_uis()[1]
    local width = math.floor(ui.width * config.width)
    local height = math.floor(ui.height * config.height)

    -- Calculate centered position with vertical offset
    local vertical_offset_lines = math.floor(ui.height * M.VERTICAL_OFFSET)
    local row = math.floor((ui.height - height) / 2) + vertical_offset_lines
    local col = math.floor((ui.width - width) / 2)

    -- Ensure window stays within screen bounds
    row = math.max(0, math.min(row, ui.height - height))

    return {
        width = width,
        height = height,
        row = row,
        col = col,
    }
end

-- Find window by name in both arrays
local function find_window_by_name(name)
    -- Search in foreground array
    for i, win_info in ipairs(M.state.foreground_windows) do
        if win_info.name == name then
            return win_info, 'foreground', i
        end
    end

    -- Search in background array
    for i, win_info in ipairs(M.state.background_windows) do
        if win_info.name == name then
            return win_info, 'background', i
        end
    end

    return nil, nil, nil
end

-- Create terminal window
function M.create_window(name, size_type, is_not_load_zsh_profile, cmd)
    size_type = size_type or 'l'
    -- If no name provided, use default name
    if not name or name == '' then
        M.state.window_counter = M.state.window_counter + 1
        name = 'Window' .. M.state.window_counter
    end

    -- Check if window with this name already exists
    local existing_win, location, index = find_window_by_name(name)
    if existing_win then
        -- Window exists, bring it to foreground
        if location == 'background' then
            -- Remove from background and add to foreground
            table.remove(M.state.background_windows, index)
            table.insert(M.state.foreground_windows, existing_win)

            -- Show the window
            vim.api.nvim_win_set_config(existing_win.win, {
                relative = 'editor',
                width = existing_win.config.width,
                height = existing_win.config.height,
                row = existing_win.config.row,
                col = existing_win.config.col,
                style = 'minimal',
                border = 'rounded',
                title = ' ' .. existing_win.name .. ' ',
                title_pos = 'center',
                hide = false,
            })
        end

        -- Switch to the window
        vim.api.nvim_set_current_win(existing_win.win)
        vim.cmd('startinsert')

        vim.notify('Window "' .. name .. '" already exists, switched to it', vim.log.levels.INFO)
        return existing_win
    end

    -- Window doesn't exist, create new one
    -- Get window size
    local win_config = get_window_size(size_type)

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Create floating window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = win_config.width,
        height = win_config.height,
        row = win_config.row,
        col = win_config.col,
        style = 'minimal',
        border = 'rounded',
        title = ' ' .. name .. ' ',
        title_pos = 'center',
    })

    -- Open terminal in the new window
    if is_not_load_zsh_profile then
        vim.fn.termopen(vim.o.shell .. ' -f')
    else
        vim.fn.termopen(vim.o.shell)
    end

    -- If cmd is provided and not empty, send it to the terminal
    if cmd and cmd ~= '' then
        -- Use vim's term_sendkeys to send command to terminal
        vim.schedule(function()
            -- Get the terminal job ID and send the command
            local job_id = vim.api.nvim_buf_get_var(buf, 'terminal_job_id')
            if job_id then
                vim.fn.jobsend(job_id, cmd .. '\r')
            end
        end)
    end

    -- Enter insert mode
    vim.cmd('startinsert')

    -- Save window information
    local window_info = {
        win = win,
        buf = buf,
        name = name,
        size_type = size_type,
        config = win_config,
    }

    -- Add to foreground window array
    table.insert(M.state.foreground_windows, window_info)

    return window_info
end

-- Find window index in array
local function find_window_index(windows, win_id)
    for i, win_info in ipairs(windows) do
        if win_info.win == win_id then
            return i
        end
    end
    return nil
end

-- Remove closed window from arrays
function M.remove_closed_window(win_id)
    -- Try to remove from foreground array
    local index = find_window_index(M.state.foreground_windows, win_id)
    if index then
        local win_info = table.remove(M.state.foreground_windows, index)
        return true
    end

    -- Try to remove from background array
    index = find_window_index(M.state.background_windows, win_id)
    if index then
        local win_info = table.remove(M.state.background_windows, index)
        return false
    end
    return false
end

-- Show window (from background to foreground)
function M.show_window()
    -- If no background windows
    if #M.state.background_windows == 0 then
        -- If no foreground windows either, create a default window
        if #M.state.foreground_windows == 0 then
            M.create_window('Window0', 'l')
        else
            vim.notify('No background windows available', vim.log.levels.INFO)
        end
        return
    end

    -- Pop the last window from background array
    local win_info = table.remove(M.state.background_windows)

    -- Check if window is still valid
    if not vim.api.nvim_win_is_valid(win_info.win) then
        -- Window was closed, try next one recursively
        M.show_window()
        return
    end

    -- Show the window
    vim.api.nvim_win_set_config(win_info.win, {
        relative = 'editor',
        width = win_info.config.width,
        height = win_info.config.height,
        row = win_info.config.row,
        col = win_info.config.col,
        style = 'minimal',
        border = 'rounded',
        title = ' ' .. win_info.name .. ' ',
        title_pos = 'center',
        hide = false,
    })

    -- Switch to the window
    vim.api.nvim_set_current_win(win_info.win)

    -- Add to foreground array
    table.insert(M.state.foreground_windows, win_info)

    -- Enter insert mode (if terminal)
    vim.cmd('startinsert')
end

-- Show window by name (move to foreground)
function M.show_window_by_name(name)
    if not name or name == '' then
        vim.notify('Please provide a window name', vim.log.levels.WARN)
        return
    end

    local win_info, location, index = find_window_by_name(name)

    if not win_info then
        vim.notify('Window "' .. name .. '" not found', vim.log.levels.WARN)
        return
    end

    if location == 'background' then
        -- Remove from background and add to foreground
        table.remove(M.state.background_windows, index)
        table.insert(M.state.foreground_windows, win_info)

        -- Show the window
        vim.api.nvim_win_set_config(win_info.win, {
            relative = 'editor',
            width = win_info.config.width,
            height = win_info.config.height,
            row = win_info.config.row,
            col = win_info.config.col,
            style = 'minimal',
            border = 'rounded',
            title = ' ' .. win_info.name .. ' ',
            title_pos = 'center',
            hide = false,
        })
    elseif location == 'foreground' then
        -- Already in foreground, move to end (most recent)
        table.remove(M.state.foreground_windows, index)
        table.insert(M.state.foreground_windows, win_info)
    end

    -- Switch to the window
    vim.api.nvim_set_current_win(win_info.win)
    vim.cmd('startinsert')
end

-- Show or exit windows using FZF with action parameter
-- action: 'show' to show selected window, 'delete' to delete selected window
-- If FZF window is already open with the same action, close it (toggle behavior)
function M.show_or_exit_windows(action)
    action = action or 'show'  -- Default action is 'show'

    -- Check if FZF window is already open
    if M.state.fzf_window and vim.api.nvim_win_is_valid(M.state.fzf_window) then
        -- If same action is being triggered again, close the FZF window
        if M.state.fzf_action == action then
            vim.api.nvim_win_close(M.state.fzf_window, true)
            M.state.fzf_window = nil
            M.state.fzf_action = nil
            vim.notify('FZF window closed', vim.log.levels.INFO)
            return
        else
            -- If different action, close the old FZF window first
            vim.api.nvim_win_close(M.state.fzf_window, true)
            M.state.fzf_window = nil
        end
    end

    -- Check if FZF is available
    if vim.fn.exists('*fzf#run') == 0 then
        vim.notify('FZF is not installed or not available', vim.log.levels.ERROR)
        return
    end

    -- Get all window names with location info
    local window_list = {}

    -- Add foreground windows
    for _, win_info in ipairs(M.state.foreground_windows) do
        table.insert(window_list, win_info.name .. ' [foreground]')
    end

    -- Add background windows
    for _, win_info in ipairs(M.state.background_windows) do
        table.insert(window_list, win_info.name .. ' [background]')
    end

    if #window_list == 0 then
        vim.notify('No windows available', vim.log.levels.INFO)
        return
    end

    -- Determine the action and prompt message
    local action_func
    local prompt_msg

    if action == 'delete' then
        action_func = function(name)
            M.delete_window_by_name(name)
            M.state.fzf_window = nil
            M.state.fzf_action = nil
        end
        prompt_msg = 'Delete Window> '
    else  -- default to 'show'
        action_func = function(name)
            M.show_window_by_name(name)
            M.state.fzf_window = nil
            M.state.fzf_action = nil
        end
        prompt_msg = 'Select Window> '
    end

    -- FZF options with sink_replace to capture the FZF window
    local fzf_opts = {
        source = window_list,
        sink = function(selected)
            if selected then
                -- Extract window name (remove location tag)
                local name = selected:match('(.*)%s+%[')
                if name then
                    action_func(name)
                end
            end
        end,
        options = {
            '--prompt', prompt_msg,
            '--height', '40%',
            '--layout', 'reverse',
            '--border',
            '--info', 'inline',
        },
        window = {
            width = 0.6,
            height = 0.5,
            border = 'rounded',
        },
    }

    -- Run FZF and capture the window
    local fzf_result = vim.fn['fzf#run'](vim.fn['fzf#wrap'](fzf_opts))

    -- Store FZF window info for toggle functionality
    -- Try to find the FZF window in current windows
    vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)
            -- FZF creates a buffer with name starting with fzf
            if buf_name:match('fzf') then
                M.state.fzf_window = win
                M.state.fzf_action = action
                break
            end
        end
    end)
end

-- Delete window by name
function M.delete_window_by_name(name)
    if not name or name == '' then
        vim.notify('Please provide a window name', vim.log.levels.WARN)
        return
    end

    local win_info, location, index = find_window_by_name(name)

    if not win_info then
        vim.notify('Window "' .. name .. '" not found', vim.log.levels.WARN)
        return
    end

    -- Close the window if it's valid
    if vim.api.nvim_win_is_valid(win_info.win) then
        vim.api.nvim_win_close(win_info.win, true)
    end

    -- Remove from the appropriate array
    if location == 'foreground' then
        table.remove(M.state.foreground_windows, index)
    elseif location == 'background' then
        table.remove(M.state.background_windows, index)
    end

    vim.notify('Window "' .. name .. '" deleted', vim.log.levels.INFO)
end

-- Hide window (from foreground to background)
function M.hide_window()
    local current_win = vim.api.nvim_get_current_win()

    -- Find current window in foreground array
    local index = find_window_index(M.state.foreground_windows, current_win)

    if not index then
        vim.notify('Current window is not a managed terminal window', vim.log.levels.WARN)
        return
    end

    -- Remove from foreground array
    local win_info = table.remove(M.state.foreground_windows, index)

    -- Hide window (by setting hide flag)
    vim.api.nvim_win_set_config(win_info.win, {
        relative = 'editor',
        width = win_info.config.width,
        height = win_info.config.height,
        row = win_info.config.row,
        col = win_info.config.col,
        style = 'minimal',
        border = 'rounded',
        hide = true,
    })

    -- Add to background array
    table.insert(M.state.background_windows, win_info)

    -- Switch focus to last foreground window if any exist
    if #M.state.foreground_windows > 0 then
        local last_fg_win = M.state.foreground_windows[#M.state.foreground_windows]
        if vim.api.nvim_win_is_valid(last_fg_win.win) then
            vim.api.nvim_set_current_win(last_fg_win.win)
            vim.cmd('startinsert')
            return
        end
    end

    -- Otherwise, switch to any other available window
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
        if win ~= current_win and vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
            break
        end
    end
end

-- Resize window (keeping center position)
function M.resize_window(direction, delta)
    local current_win = vim.api.nvim_get_current_win()

    -- Find current window
    local index = find_window_index(M.state.foreground_windows, current_win)

    if not index then
        return
    end

    local win_info = M.state.foreground_windows[index]
    local ui = vim.api.nvim_list_uis()[1]
    local width_step = math.floor(ui.width * M.RESIZE_STEP)
    local height_step = math.floor(ui.height * M.RESIZE_STEP)

    -- Get current window config
    local config = vim.api.nvim_win_get_config(current_win)
    local old_width = config.width
    local old_height = config.height

    -- Adjust size based on direction and keep center
    if direction == 'right' then
        -- Expand width
        config.width = config.width + (width_step * delta)
    elseif direction == 'left' then
        -- Shrink width
        config.width = config.width - (width_step * delta)
    elseif direction == 'down' then
        -- Shrink height
        config.height = config.height - (height_step * delta)
    elseif direction == 'up' then
        -- Expand height
        config.height = config.height + (height_step * delta)
    end

    -- Ensure size is not too small or too large
    config.width = math.max(config.width, 20)
    config.height = math.max(config.height, 5)
    config.width = math.min(config.width, ui.width)
    config.height = math.min(config.height, ui.height)

    -- Adjust position to keep center (move by half of size change)
    local width_change = config.width - old_width
    local height_change = config.height - old_height
    config.col = config.col - math.floor(width_change / 2)
    config.row = config.row - math.floor(height_change / 2)

    -- Ensure window does not go off screen
    config.col = math.max(0, math.min(config.col, ui.width - config.width))
    config.row = math.max(0, math.min(config.row, ui.height - config.height))

    -- Apply new config
    vim.api.nvim_win_set_config(current_win, config)

    -- Update saved config
    win_info.config = {
        width = config.width,
        height = config.height,
        row = config.row,
        col = config.col,
    }
end

-- Move window position
function M.move_window(direction)
    local current_win = vim.api.nvim_get_current_win()

    -- Find current window
    local index = find_window_index(M.state.foreground_windows, current_win)

    if not index then
        return
    end

    local win_info = M.state.foreground_windows[index]
    local ui = vim.api.nvim_list_uis()[1]
    local width_step = math.floor(ui.width * M.MOVE_STEP)
    local height_step = math.floor(ui.height * M.MOVE_STEP)

    -- Get current window config
    local config = vim.api.nvim_win_get_config(current_win)

    -- Adjust position based on direction
    if direction == 'right' then
        config.col = config.col + width_step
    elseif direction == 'left' then
        config.col = config.col - width_step
    elseif direction == 'down' then
        config.row = config.row + height_step
    elseif direction == 'up' then
        config.row = config.row - height_step
    end

    -- Ensure window does not go off screen
    config.col = math.max(0, math.min(config.col, ui.width - config.width))
    config.row = math.max(0, math.min(config.row, ui.height - config.height))

    -- Apply new config
    vim.api.nvim_win_set_config(current_win, config)

    -- Update saved config
    win_info.config = {
        width = config.width,
        height = config.height,
        row = config.row,
        col = config.col,
    }
end

function M.next_windows()
  -- 1. Check if there are background windows
  if #M.state.background_windows == 0 then
    vim.notify('No background windows available', vim.log.levels.INFO)
    return
  end

  -- 2. Get current window
  local current_win = vim.api.nvim_get_current_win()
  local current_index = find_window_index(M.state.foreground_windows, current_win)

  -- Only proceed if current window is a managed foreground window
  if not current_index then
    vim.notify('Current window is not a managed terminal window', vim.log.levels.WARN)
    return
  end

  -- 3. Move current window to background (add to end of background array)
  local current_win_info = table.remove(M.state.foreground_windows, current_index)

  -- Hide the window
  vim.api.nvim_win_set_config(current_win_info.win, {
    relative = 'editor',
    width = current_win_info.config.width,
    height = current_win_info.config.height,
    row = current_win_info.config.row,
    col = current_win_info.config.col,
    style = 'minimal',
    border = 'rounded',
    hide = true,
  })

  -- Add to end of background array
  table.insert(M.state.background_windows, current_win_info)

  -- 4. Move first background window to foreground
  local first_bg_win = table.remove(M.state.background_windows, 1)

  -- Check if window is still valid
  if not vim.api.nvim_win_is_valid(first_bg_win.win) then
    -- Window was closed, try recursively
    vim.notify('Background window was closed, trying next one', vim.log.levels.INFO)
    -- Re-trigger the function to try next window
    vim.schedule(function()
      vim.keymap.set({'n', 't'}, '<M-\\>', function() end)
      -- Call the keybind again
      require('windows_manager')['setup_keymaps']()
    end)
    return
  end
  -- Show the window
  vim.api.nvim_win_set_config(first_bg_win.win, {
    relative = 'editor',
    width = first_bg_win.config.width,
    height = first_bg_win.config.height,
    row = first_bg_win.config.row,
    col = first_bg_win.config.col,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. first_bg_win.name .. ' ',
    title_pos = 'center',
    hide = false,
  })

  -- Add to foreground array
  table.insert(M.state.foreground_windows, first_bg_win)

  -- Switch to the window and enter insert mode
  vim.api.nvim_set_current_win(first_bg_win.win)
  vim.cmd('startinsert')
end

-- Setup keymaps
function M.setup_keymaps()
  -- Alt+/ : Show window
  vim.keymap.set({'n', 't'}, '<M-/>', function()
    -- 如果当前窗口在前台，则退到后台
    local index = find_window_index(M.state.foreground_windows, vim.api.nvim_get_current_win())
    if index then
      M.hide_window()
    else
      M.show_window()
      return
    end
  end, { desc = 'Show window from background' })

  -- Alt+\ : Switch window (send current to background, bring first background to foreground)
  vim.keymap.set({'n', 't'}, '<M-\\>', function()
    M.next_windows()
  end, { desc = 'Switch window: send current to background, bring first background to foreground' })

  -- Shift+Alt+f : Search windows with FZF
  vim.keymap.set({'n', 't'}, '<S-M-l>', function()
    M.show_or_exit_windows('show')
  end, { desc = 'Search and select window with FZF' })

  vim.keymap.set({'n', 't'}, '<S-M-d>', function()
    M.show_or_exit_windows('delete')
  end, { desc = 'delete window with FZF' })

  -- Alt+Arrow keys: Resize window (keeping center)
  -- Right: expand width, Left: shrink width
  -- Up: expand height, Down: shrink height
  vim.keymap.set({'n', 't'}, '<C-M-Right>', function()
    M.resize_window('right', 1)
    end, { desc = 'Expand window width' })

    vim.keymap.set({'n', 't'}, '<C-M-Left>', function()
        M.resize_window('left', 1)
    end, { desc = 'Shrink window width' })

    vim.keymap.set({'n', 't'}, '<C-M-Up>', function()
        M.resize_window('up', 1)
    end, { desc = 'Expand window height' })

    vim.keymap.set({'n', 't'}, '<C-M-Down>', function()
        M.resize_window('down', 1)
    end, { desc = 'Shrink window height' })

    -- Shift+Alt+Arrow keys: Move window
    vim.keymap.set({'n', 't'}, '<S-M-Right>', function()
        M.move_window('right')
    end, { desc = 'Move window right' })

    vim.keymap.set({'n', 't'}, '<S-M-Left>', function()
        M.move_window('left')
    end, { desc = 'Move window left' })

    vim.keymap.set({'n', 't'}, '<S-M-Down>', function()
        M.move_window('down')
    end, { desc = 'Move window down' })

    vim.keymap.set({'n', 't'}, '<S-M-Up>', function()
        M.move_window('up')
    end, { desc = 'Move window up' })
end

-- Get all window names for completion
local function get_all_window_names()
    local names = {}

    -- Collect from foreground windows
    for _, win_info in ipairs(M.state.foreground_windows) do
        table.insert(names, win_info.name)
    end

    -- Collect from background windows
    for _, win_info in ipairs(M.state.background_windows) do
        table.insert(names, win_info.name)
    end

    return names
end

-- Setup commands
function M.setup_commands()
    -- Create window command
    vim.api.nvim_create_user_command('WinCreate', function(opts)
        local args = vim.split(opts.args, '%s+')
        local name = args[1]
        local size = args[2]
        M.create_window(name, size)
    end, {
        nargs = '*',
        desc = 'Create a new terminal window (name and size optional)',
    })

    -- Show window by name command with completion
    vim.api.nvim_create_user_command('WindowsShow', function(opts)
        M.show_window_by_name(opts.args)
    end, {
        nargs = 1,
        desc = 'Show window by name (bring to foreground)',
        complete = function(arg_lead, cmd_line, cursor_pos)
            local names = get_all_window_names()
            -- Filter names that start with the current input
            if arg_lead == '' then
                return names
            end
            local matches = {}
            for _, name in ipairs(names) do
                if name:lower():find(arg_lead:lower(), 1, true) == 1 then
                    table.insert(matches, name)
                end
            end
            return matches
        end,
    })

    -- Search windows with FZF command
    vim.api.nvim_create_user_command('WindowsSearch', function()
        M.search_windows()
    end, {
        desc = 'Search and select window with FZF',
    })

    -- Show window status command
    vim.api.nvim_create_user_command('WinStatus', function()
        print('Foreground windows: ' .. #M.state.foreground_windows)
        for i, win in ipairs(M.state.foreground_windows) do
            print('  ' .. i .. '. ' .. win.name .. ' (size: ' .. win.size_type .. ')')
        end
        print('Background windows: ' .. #M.state.background_windows)
        for i, win in ipairs(M.state.background_windows) do
            print('  ' .. i .. '. ' .. win.name .. ' (size: ' .. win.size_type .. ')')
        end
    end, {
        desc = 'Show window manager status',
    })
end

-- Update all windows when vim is resized
function M.update_all_windows_on_resize()
    local ui = vim.api.nvim_list_uis()[1]
    if not ui then
        return
    end

    -- Update all foreground windows
    for _, win_info in ipairs(M.state.foreground_windows) do
        if vim.api.nvim_win_is_valid(win_info.win) then
            -- Recalculate window size based on original size_type
            local new_config = get_window_size(win_info.size_type)

            -- Update the window configuration
            vim.api.nvim_win_set_config(win_info.win, {
                relative = 'editor',
                width = new_config.width,
                height = new_config.height,
                row = new_config.row,
                col = new_config.col,
                style = 'minimal',
                border = 'rounded',
                title = ' ' .. win_info.name .. ' ',
                title_pos = 'center',
                hide = false,
            })

            -- Update saved config
            win_info.config = new_config
        end
    end

    -- Update all background windows
    for _, win_info in ipairs(M.state.background_windows) do
        if vim.api.nvim_win_is_valid(win_info.win) then
            -- Recalculate window size based on original size_type
            local new_config = get_window_size(win_info.size_type)

            -- Update the window configuration (keep it hidden)
            vim.api.nvim_win_set_config(win_info.win, {
                relative = 'editor',
                width = new_config.width,
                height = new_config.height,
                row = new_config.row,
                col = new_config.col,
                style = 'minimal',
                border = 'rounded',
                title = ' ' .. win_info.name .. ' ',
                title_pos = 'center',
                hide = true,
            })

            -- Update saved config
            win_info.config = new_config
        end
    end
end

-- Setup autocmd for window cleanup
function M.setup_autocmd()
    -- Create augroup for window manager
    local augroup = vim.api.nvim_create_augroup('WindowsManager', { clear = true })

    -- Listen for window close events
    vim.api.nvim_create_autocmd('WinClosed', {
        group = augroup,
        callback = function(args)
            local win_id = tonumber(args.match)
            if win_id then
                local is_in_front = M.remove_closed_window(win_id)
                if is_in_front and #M.state.foreground_windows == 0 and #M.state.background_windows > 0 then
                  M.show_window()
                end
            end
        end,
        desc = 'Remove closed window from windows manager',
    })

    -- Listen for vim resize events
    vim.api.nvim_create_autocmd('VimResized', {
        group = augroup,
        callback = function()
            M.update_all_windows_on_resize()
        end,
        desc = 'Update all managed windows when nvim window is resized',
    })
end

-- Initialize
function M.setup()
    M.setup_keymaps()
    M.setup_commands()
    M.setup_autocmd()
end

return M
