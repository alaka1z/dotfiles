return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        {"<leader>f", group = "Find"},
        {"<leader>s", group = "Search"},
      },

      icons = {
        group = "",
      },
    },
  },
}
