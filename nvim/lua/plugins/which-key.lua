return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        {"<leader>f", group = "Find", icon = "󰈞"},
        {"<leader>g", group = "Git" },
        {"<leader>s", group = "Search"},
        {"<leader>r", desc = "Reload Config", icon = "󰑓" },
        {"<leader>w", desc = "Save All", icon = "󰆓"},
        {
          "<leader>l",
          group = "LaTeX",
          icon = "󰙩",
          cond = function()
            return vim.bo.filetype == "tex"
          end,
        },
      },

      -- Remove the default + prefix from group names
      icons = {
        group = "",
      },
    },
  },
}
