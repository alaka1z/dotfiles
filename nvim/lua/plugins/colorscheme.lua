return {
  {
    "catppuccin/nvim",
    name = "catppuccin",

    -- Load the colorscheme before other UI plugins
    priority = 1000,

    config = function()
      require("catppuccin").setup({
        flavour = "mocha",

        -- Let WezTerm provide the terminal background
        -- transparent_background = true,
      })

      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  {
    "folke/tokyonight.nvim",
  },

  {
    "ellisonleao/gruvbox.nvim",
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
  },
}
