return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,

    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
  },

  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    -- priority = 1000, -- High priority ensures it loads before other plugins
    -- config = function()
    --   require("gruvbox").setup({
    --     transparent_mode = true, -- Enables transparency
    --   })
    -- end,
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
  },
}
