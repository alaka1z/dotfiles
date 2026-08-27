return {
  {
    "nvim-treesitter/nvim-treesitter",

    -- Load Treesitter immediately so parsers are available for filetype hooks
    lazy = false,

    -- Keep installed parsers updated when the plugin updates
    build = ":TSUpdate",

    config = function()
      -- Enable Treesitter highlighting only for filetypes we explicitly choose
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua" },
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
}
