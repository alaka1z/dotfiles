return {
  {
    "nvim-mini/mini.icons",
    version = false,
    opts = {},
  },

  -- Keep devicons available for plugins that expect it directly
  {
    "nvim-tree/nvim-web-devicons",
    opts = {},
  },

  -- Follow the active colorscheme automatically
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "auto",
      },
    },
  },
}
