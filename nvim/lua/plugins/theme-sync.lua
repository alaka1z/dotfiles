return {
  {
    "alaka1z/theme-sync.nvim",

    config = function()
      local themes = dofile(
        vim.fn.expand("~/.config/theme-sync/themes.lua")
      )

      require("theme-sync").setup({
        themes = themes,

        on_theme_changed = function()
          vim.system({
            "pwsh.exe",
            "-NoProfile",
            "-File",
            vim.fn.expand("~/.config/glazewm/theme-sync.ps1"),
          })
        end,
      })
    end,
  },
}
