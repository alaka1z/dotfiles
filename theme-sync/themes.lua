-- Order controls the picker, with the first theme used as the fallback
return {
  {
    id = "catppuccin",
    nvim = "catppuccin-mocha",
    wezterm = "Catppuccin Mocha",

    set_nvim_transparency = function(enabled)
      require("catppuccin").setup({
        transparent_background = enabled,
      })
    end,

    get_nvim_colors = function()
      local palette = require("catppuccin.palettes").get_palette("mocha")

      return {
        foreground = palette.text,
        background = palette.base,
      }
    end,
  },

  {
    id = "rose_pine",
    nvim = "rose-pine",
    wezterm = "rose-pine",

    set_nvim_transparency = function(enabled)
      require("rose-pine").setup({
        styles = {
          transparency = enabled,
        },
      })
    end,

    get_nvim_colors = function()
      local palette = require("rose-pine.palette")

      return {
        foreground = palette.text,
        background = palette.base,
      }
    end,
  },

  {
    id = "gruvbox",
    nvim = "gruvbox",
    wezterm = "GruvboxDark",

    set_nvim_transparency = function(enabled)
      require("gruvbox").setup({
        transparent_mode = enabled,
      })
    end,

    get_nvim_colors = function()
      local foreground = vim.api.nvim_get_hl(0, {
        name = "GruvboxFg1",
        link = false,
      }).fg

      local background = vim.api.nvim_get_hl(0, {
        name = "GruvboxBg0",
        link = false,
      }).fg

      return {
        foreground = string.format("#%06x", foreground),
        background = string.format("#%06x", background),
      }
    end,
  },

  {
    id = "gruvbox_material",
    nvim = "gruvbox-material",
    wezterm = "Gruvbox Material (Gogh)",

    set_nvim_transparency = function(enabled)
      vim.g.gruvbox_material_transparent_background = enabled and 1 or 0
    end,

    get_nvim_colors = function()
      local config = vim.fn["gruvbox_material#get_configuration"]()
      local palette = vim.fn["gruvbox_material#get_palette"](
        config.background,
        config.foreground,
        config.colors_override
      )

      return {
        foreground = palette.fg0[1],
        background = palette.bg0[1],
      }
    end,
  },

  {
    id = "tokyonight",
    nvim = "tokyonight-moon",
    wezterm = "Tokyo Night Moon",

    set_nvim_transparency = function(enabled)
      require("tokyonight").setup({
        transparent = enabled,
      })
    end,

    get_nvim_colors = function()
      local options = require("tokyonight.config").options
      local colors = require("tokyonight.colors").setup(options)

      return {
        foreground = colors.fg,
        background = colors.bg,
      }
    end,
  },
}
