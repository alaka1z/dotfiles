return {
  {
    "catppuccin/nvim",
    name = "catppuccin",

    -- Load the default colorscheme before other UI plugins
    priority = 1000,

    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = false,
  },

  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
  },
}
