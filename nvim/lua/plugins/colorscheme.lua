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
        transparent_background = true,
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
