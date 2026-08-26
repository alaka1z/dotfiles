return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        {"<leader>f", group = "Find"},
        {"<leader>s", group = "Search"},
        {"<leader>r", desc = "Reload config", icon = "󰑓" },
        { "<leader>g", group = "Git" },
      },

      icons = {
        group = "",
      },
    },
  },
}
