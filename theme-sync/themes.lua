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
  },

  {
    id = "gruvbox_material",
    nvim = "gruvbox-material",
    wezterm = "Gruvbox Material (Gogh)",

    set_nvim_transparency = function(enabled)
      vim.g.gruvbox_material_transparent_background = enabled and 1 or 0
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
  },
}
