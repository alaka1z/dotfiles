return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        {"<leader>f", group = "Find"},
        { "<leader>g", group = "Git" },
        {"<leader>s", group = "Search"},
        {"<leader>r", desc = "Reload config", icon = "󰑓" },
      },

      -- Remove the default + prefix from group names
      icons = {
        group = "",
      },
    },
  },
}
