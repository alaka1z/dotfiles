return {
  {
    "lewis6991/gitsigns.nvim",

    -- Load for file buffers so Git signs are available immediately
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
