local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Behaviour

-- Set the default opening size
config.initial_cols = 100
config.initial_rows = 32

-- Launch PowerShell 7 without its startup banner
config.default_prog = { "pwsh.exe", "-NoLogo" }

-- Remove the normal Windows title bar
config.window_decorations = "RESIZE"

-- Disable WezTerm's mux SSH agent integration
config.mux_enable_ssh_agent = false

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
    -- Type ~ on keyboards without a dedicated tilde key
    {
        key = "Escape",
        mods = "SHIFT",
        action = wezterm.action.SendString("~"),
    },

    -- Maximize the window without entering fullscreen
    {
        key = "Enter",
        mods = "ALT",
        action = wezterm.action_callback(function(window)
            window:maximize()
        end),
    },

    -- Work around a Windows title-bar flash when returning to fullscreen
    --
    -- Enter fullscreen from a normally decorated window, then restore the
    -- titleless RESIZE configuration while leaving fullscreen
    -- {
    --     key = "Enter",
    --     mods = "ALT",
    --     action = wezterm.action_callback(function(window, pane)
    --         local overrides = window:get_config_overrides() or {}
    --
    --         if window:get_dimensions().is_full_screen then
    --             overrides.window_decorations = "RESIZE"
    --         else
    --             overrides.window_decorations = "TITLE|RESIZE"
    --         end
    --
    --         window:set_config_overrides(overrides)
    --         window:perform_action(wezterm.action.ToggleFullScreen, pane)
    --     end),
    -- },
}

-- Appearance

-- Main terminal font
config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font Mono",
  {
    family = "CustomGlyphs",
    scale = 1.5,
  },
})

config.font_size = 12.0

-- Background opacity
-- config.window_background_opacity = 0.9
-- config.text_background_opacity = 0.9

-- config.color_scheme = "Catppuccin Mocha"

-- Thin blinking vertical cursor
config.default_cursor_style = "BlinkingBar"


-- ============================================================
-- Optional / experiments
-- ============================================================

-- Remove all space between terminal content and the window edges
-- Currently disabled so WezTerm uses its default padding

-- config.window_padding = {
--     left = 0,
--     right = 0,
--     top = 0,
--     bottom = 0,
-- }

-- Alternative cursor style:
-- config.default_cursor_style = "BlinkingBlock"

local theme_schemes = {
    catppuccin = "Catppuccin Mocha",
    tokyonight = "Tokyo Night Moon",
    gruvbox = "GruvboxDark",
    ["rose-pine"] = "rose-pine",
}

local theme = "catppuccin-mocha"

local local_appdata = os.getenv("LOCALAPPDATA")

if local_appdata then
    local path = local_appdata .. "\\nvim-data\\theme-sync-test"
    local file = io.open(path, "r")

    if file then
        local saved = file:read("*l")
        file:close()

        if saved and theme_schemes[saved] then
            theme = saved
        end
    end
end

config.color_scheme = theme_schemes[theme]

local function apply_dynamic_scheme(pane, scheme_name)
    local schemes = wezterm.color.get_builtin_schemes()
    local scheme = schemes[scheme_name]

    if not scheme then
        wezterm.log_error("Unknown color scheme: " .. scheme_name)
        return
    end

    local sequences = {}

    -- ANSI colors 0-7
    for i, color in ipairs(scheme.ansi or {}) do
        table.insert(
            sequences,
            string.format("\27]4;%d;%s\27\\", i - 1, color)
        )
    end

    -- Bright ANSI colors 8-15
    for i, color in ipairs(scheme.brights or {}) do
        table.insert(
            sequences,
            string.format("\27]4;%d;%s\27\\", i + 7, color)
        )
    end

    if scheme.foreground then
        table.insert(sequences, "\27]10;" .. scheme.foreground .. "\27\\")
    end

    if scheme.background then
        table.insert(sequences, "\27]11;" .. scheme.background .. "\27\\")
    end

    local cursor = scheme.cursor_bg or scheme.cursor_border

    if cursor then
        table.insert(sequences, "\27]12;" .. cursor .. "\27\\")
    end

    pane:inject_output(table.concat(sequences))
end

wezterm.on("user-var-changed", function(window, pane, name, value)
    if name ~= "NVIM_THEME_TEST" then
        return
    end

    local scheme_name = theme_schemes[value]

    if not scheme_name then
        wezterm.log_error("Unknown theme: " .. value)
        return
    end

    apply_dynamic_scheme(pane, scheme_name)
end)

return config
