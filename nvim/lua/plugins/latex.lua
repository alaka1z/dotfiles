local texpresso_distro = "Ubuntu-24.04"

local windows_home = vim.fn.expand("~"):gsub("\\", "/")
local drive, rest = windows_home:match("^([A-Za-z]):/(.*)$")
local wsl_home = "/mnt/" .. drive:lower() .. "/" .. rest
local texpresso_wrapper = wsl_home .. "/.config/texpresso/texpresso-vcxsrv"

return {
  {
    "alaka1z/vimtex",
    branch = "texpresso-wsl-minimal",

    -- Keep VimTeX available from startup for TeX commands and callbacks
    lazy = false,

    init = function()
      -- Disable VimTeX's default mappings in favor of our TeX-local mappings
      vim.g.vimtex_mappings_enabled = 0

      vim.g.vimtex_compiler_method = "texpresso"

      vim.g.vimtex_compiler_texpresso = {
        wsl = texpresso_distro,

        executable = {
          "wsl.exe",
          "-d",
          texpresso_distro,
          "--",
          "sh",
          texpresso_wrapper,
        },

        options = {
          "-texlive",
        },
      }
    end,
  },
}
