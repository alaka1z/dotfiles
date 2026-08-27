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
        -- Keep the explorer narrow enough to preserve editor space
        width = 32,
      },

      -- Close the explorer after opening a file
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
