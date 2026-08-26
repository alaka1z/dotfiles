return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    opts = {
      window = {
        width = 32,
      },

      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            require("neo-tree.command").execute({
              action = "close",
            })
          end,
        },
      },
    },

    keys = {
      {
        "<leader>e",
        "<cmd>Neotree toggle<cr>",
        desc = "Explorer",
      },
    },
  },
}
