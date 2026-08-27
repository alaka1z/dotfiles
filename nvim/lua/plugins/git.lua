return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},

    keys = {
      {
        "<leader>gp",
        "<cmd>Gitsigns preview_hunk<cr>",
        desc = "Preview hunk",
      },
      {
        "<leader>gb",
        "<cmd>Gitsigns blame_line<cr>",
        desc = "Blame line",
      },
    },
  },
}
