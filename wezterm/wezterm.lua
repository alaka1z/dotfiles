-- Load WezTerm's Lua API and create the configuration object.
local wezterm = require("wezterm")
local config = wezterm.config_builder()


-- ============================================================
-- Behaviour
-- ============================================================


-- Launch PowerShell 7 whenever WezTerm starts.
-- -NoLogo removes the PowerShell startup banner.
config.default_prog = { "pwsh.exe", "-NoLogo" }


-- Remove the normal Windows title bar while keeping the resize border.
-- The window can still be moved with Ctrl + Shift + left-drag.
config.window_decorations = "RESIZE"


-- Hide the tab bar when only one tab exists, and use the simpler tab style.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false


-- Remove the "+" button from the tab bar.
-- Tabs can still be opened with Ctrl + Shift + T.
-- config.show_new_tab_button_in_tab_bar = false


-- Show each tab's current directory instead of the process/window title.
wezterm.on("format-tab-title", function(tab)
    local cwd = tab.active_pane.current_working_dir

    if cwd and cwd.scheme == "file" then
        local path = cwd.file_path

        -- Remove any trailing slash, then take only the final folder name.
        path = path:gsub("[/\\]+$", "")
        local folder = path:match("([^/\\]+)$")

        if folder and folder ~= "" then
            return " " .. folder .. " "
        end
    end

    -- Fall back to WezTerm's normal pane title if no cwd is available.
    return " " .. tab.active_pane.title .. " "
end)

config.keys = {
    -- Type ~ on keyboards without a dedicated tilde key.
    {
        key = "Escape",
        mods = "SHIFT",
        action = wezterm.action.SendString("~"),
    },

    -- future binding
    -- {
    --     ...
    -- },
}

-- ============================================================
-- Appearance
-- ============================================================

-- Main terminal font.
-- The Nerd Font Mono variant includes extra developer/icon glyphs
-- while remaining monospaced for terminal and Neovim use.
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 12.0

-- Character-cell width multiplier.
-- 1 is the font's normal width; values below 1 make text more condensed.
config.cell_width = 1

-- Background opacity: 1 is fully opaque, 0.9 is 90% opaque, etc.
config.window_background_opacity = 1

-- Terminal and tab-bar colours.
--[[
config.colors = {
    -- Almost black with a slight purple tint.
    background = "#0c0b0f",

    tab_bar = {
        -- Matching backgrounds keep the tab bar flat and minimal.
        background = "#0c0b0f",

        active_tab = {
            bg_color = "#0c0b0f",
            fg_color = "#bea3c7", -- muted lavender
        },

        inactive_tab = {
            bg_color = "#0c0b0f",
            fg_color = "#f8f2f5", -- soft off-white
        },

        new_tab = {
            bg_color = "#0c0b0f",
            fg_color = "#f8f2f5",
        },
    },
}
]]

-- Use Catppuccin Mocha as the terminal colour scheme.
config.color_scheme = "Catppuccin Mocha"

-- Thin blinking vertical cursor.
config.default_cursor_style = "BlinkingBar"


-- ============================================================
-- Optional / experiments
-- ============================================================

-- Remove all space between terminal content and the window edges.
-- Currently disabled so WezTerm uses its default padding.
--[[
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}
]]

-- Alternative cursor style:
-- config.default_cursor_style = "BlinkingBlock"


-- Give the completed configuration back to WezTerm.
return config