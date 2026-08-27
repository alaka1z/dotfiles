-- Load WezTerm's Lua API and create the configuration object.
local wezterm = require("wezterm")
local config = wezterm.config_builder()


-- Behaviour

-- Launch PowerShell 7 without its startup banner
config.default_prog = { "pwsh.exe", "-NoLogo" }

-- Remove the normal Windows title bar
config.window_decorations = "RESIZE"


-- Hide the tab bar until more than one tab exists
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false


-- Show the current directory as the tab title
wezterm.on("format-tab-title", function(tab)
    local cwd = tab.active_pane.current_working_dir

    if cwd and cwd.scheme == "file" then
        local path = cwd.file_path

        -- Remove any trailing slash, then take only the final folder name
        path = path:gsub("[/\\]+$", "")
        local folder = path:match("([^/\\]+)$")

        if folder and folder ~= "" then
            return " " .. folder .. " "
        end
    end

    -- Fall back to WezTerm's normal pane title if no cwd is available
    return " " .. tab.active_pane.title .. " "
end)

config.keys = {
    -- Type ~ on keyboards without a dedicated tilde key.
    {
        key = "Escape",
        mods = "SHIFT",
        action = wezterm.action.SendString("~"),
    },

    -- Work around a Windows title-bar flash when returning to fullscreen.
    --
    -- Enter fullscreen from a normally decorated window, then restore the
    -- titleless RESIZE configuration while leaving fullscreen.
    {
        key = "Enter",
        mods = "ALT",
        action = wezterm.action_callback(function(window, pane)
            local overrides = window:get_config_overrides() or {}

            if window:get_dimensions().is_full_screen then
                overrides.window_decorations = "RESIZE"
            else
                overrides.window_decorations = "TITLE|RESIZE"
            end

            window:set_config_overrides(overrides)
            window:perform_action(wezterm.action.ToggleFullScreen, pane)
        end),
    },
}

-- Appearance

-- Main terminal font
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 12.0

-- Background opacity
-- config.window_background_opacity = 0.5
-- config.text_background_opacity = 0.5

config.color_scheme = "Catppuccin Mocha"

-- Thin blinking vertical cursor
config.default_cursor_style = "BlinkingBar"


-- ============================================================
-- Optional / experiments
-- ============================================================

-- Remove all space between terminal content and the window edges.
-- Currently disabled so WezTerm uses its default padding.

-- config.window_padding = {
--     left = 0,
--     right = 0,
--     top = 0,
--     bottom = 0,
-- }

-- Alternative cursor style:
-- config.default_cursor_style = "BlinkingBlock"

return config
