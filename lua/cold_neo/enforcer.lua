local M = {}

-- 1. STRICT ALLOW LIST
M.allowed_apps = {
    linux = { "zathura", "okular", "evince", "atril" },
    mac = { "Skim", "Preview", "Adobe", "sioyek" },
    windows = { "SumatraPDF", "Acrobat", "Chrome", "Edge" }
}

local uname = vim.loop.os_uname().sysname
local is_mac = uname == "Darwin"
local is_linux = uname == "Linux"
local is_windows = string.find(uname, "Windows")

local function exec(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result
end

-- 2. GET APP NAME (Unchanged)
function M.get_current_app_name()
    if is_linux then
        return exec("wmctrl -xa $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5)")
    elseif is_mac then
        local cmd = "osascript -e 'tell application \"System Events\" to get name of first application process whose frontmost is true'"
        return vim.trim(exec(cmd))
    elseif is_windows then
        return "neovide" -- Placeholder
    end
end

-- 3. CAPTURE ID (No longer needed for Neovide, but kept for compatibility)
function M.capture_current_window_id() 
    -- We now target the app "neovide" directly by name, so this is passive.
end

-- 4. FORCE NEOVIDE TO FRONT
function M.focus_neovide()
    -- print(">> PULLING FOCUS BACK <<") -- Uncomment for debug
    
    if is_linux then
        -- wmctrl -x -a attempts to activate window with class 'neovide'
        os.execute("wmctrl -xa neovide")
    elseif is_mac then
        -- AppleScript to force Neovide to front
        os.execute("osascript -e 'tell application \"neovide\" to activate'")
    end
end

-- 5. THE JUDGE
function M.enforce_focus()
    local current_app = M.get_current_app_name()
    if not current_app or current_app == "" then return end
    
    current_app = string.lower(vim.trim(current_app))

    -- A. IS IT NEOVIDE? (The most common safe case)
    if string.find(current_app, "neovide") then
        return -- Safe! You are working.
    end

    -- B. IS IT A PDF READER?
    local allowed_list = {}
    if is_linux then allowed_list = M.allowed_apps.linux
    elseif is_mac then allowed_list = M.allowed_apps.mac
    elseif is_windows then allowed_list = M.allowed_apps.windows end

    for _, pdf_app in pairs(allowed_list) do
        if string.find(current_app, string.lower(pdf_app)) then
            return -- Safe! You are reading.
        end
    end

    -- C. EVERYTHING ELSE IS BANNED (Terminals, Browsers, Finder, etc.)
    M.focus_neovide()
end

return M
