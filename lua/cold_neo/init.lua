local M = {}
local enforcer = require("cold_neo.enforcer")

M.active = false
M.timer_handle = nil
M.release_time = nil
M.original_statusline = nil -- Store your old config here

-- HELPER: Hijack specific commands
local function set_locks(enable)
    local blocked_commands = {
        "q", "wq", "qa", "x", "q!", "wq!", "qa!", "x!",
        "split", "vsplit", "sp", "vsp", "new", "vnew",
        "tabnew", "tabe", "tabedit",
        "e", "edit", "bnext", "bprev", "bn", "bp",
        "Explore", "Netrw", "Lexplore"
    }

    if enable then
        vim.keymap.set('n', 'ZZ', '<cmd>ColdCheck<CR>', { buffer = true })
        vim.keymap.set('n', 'ZQ', '<cmd>ColdCheck<CR>', { buffer = true })
        vim.keymap.set('n', '<C-w>', '<cmd>ColdCheck<CR>', { buffer = true })
        local hijack = "cnoreabbrev <expr> %s (getcmdtype() == ':' && getcmdline() == '%s') ? 'ColdCheck' : '%s'"
        for _, cmd in ipairs(blocked_commands) do
            vim.cmd(string.format(hijack, cmd, cmd, cmd))
        end
        vim.api.nvim_create_user_command("ColdCheck", M.guard_cmd, {})
    else
        vim.keymap.del('n', 'ZZ', { buffer = true })
        vim.keymap.del('n', 'ZQ', { buffer = true })
        pcall(vim.keymap.del, 'n', '<C-w>', { buffer = true })
        for _, cmd in ipairs(blocked_commands) do
            vim.cmd("cunabbrev " .. cmd)
        end
        vim.api.nvim_del_user_command("ColdCheck")
    end
end

-- HELPER: Manage the Visuals
local function set_ui(enable)
    if enable then
        -- 1. Save original statusline
        M.original_statusline = vim.o.statusline
        
        -- 2. Set Minimalist Prison Statusline
        -- %f = file path, %m = modified flag, %= = right align separator
        -- The luaeval call pulls the timer string dynamically
        vim.o.statusline = "%f %m %= %#ErrorMsg#%{luaeval('require(\"cold_neo\").get_status_string()')}%*"
        
        -- 3. Neovide Settings
        if vim.g.neovide then
            vim.g.neovide_fullscreen = true
            vim.g.neovide_scale_factor = 1.2
            vim.g.neovide_hide_mouse_when_typing = true
        end
    else
        -- Restore original
        if M.original_statusline then
            vim.o.statusline = M.original_statusline
        end
        
        if vim.g.neovide then 
            vim.g.neovide_fullscreen = false
            vim.g.neovide_scale_factor = 1.0 
        end
    end
end

function M.guard_cmd()
    if not M.active then return end
    local remaining = math.ceil((M.release_time - os.time()) / 60)
    vim.notify("❄️ NO ESCAPE. Focus on this file. (" .. remaining .. "m left)", vim.log.levels.ERROR)
    vim.cmd("silent! !echo -ne '\\007'") 
end

local function loop_check()
    if not M.active then return end

    if os.time() > M.release_time then
        M.stop_session()
        vim.notify("❄️ Cold Neo: Session Complete.", vim.log.levels.INFO)
        return
    end

    -- Force statusline redraw to update the timer
    vim.cmd("redrawstatus")

    pcall(enforcer.enforce_focus)
end

function M.start_session(opts)
    local minutes = tonumber(opts.args) or 1
    M.release_time = os.time() + (minutes * 60)
    M.active = true
    
    set_locks(true)
    set_ui(true) -- Trigger the UI changes
    
    enforcer.capture_current_window_id()

    if M.timer_handle then M.timer_handle:close() end
    M.timer_handle = vim.loop.new_timer()
    M.timer_handle:start(1000, 2000, vim.schedule_wrap(loop_check))
    
    if vim.fn.exists(":VimtexCompile") == 2 then vim.cmd("VimtexCompile") end
    print("❄️ Cold Neo: LOCKED.")
end

function M.stop_session()
    M.active = false
    set_locks(false)
    set_ui(false) -- Revert UI changes
    
    if M.timer_handle then M.timer_handle:close(); M.timer_handle = nil end
    print("❄️ Cold Neo: Session stopped manually.")
end

-- PUBLIC API for statusline
function M.get_status_string()
    if not M.active then return "" end
    local remaining = math.ceil((M.release_time - os.time()) / 60)
    return " ❄️ " .. remaining .. "m "
end

return M
