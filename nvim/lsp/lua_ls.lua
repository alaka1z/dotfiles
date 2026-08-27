return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },

  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".git",
  },

  settings = {
    Lua = {
      -- Match the Lua runtime embedded in Neovim
      runtime = {
        version = "LuaJIT",
      },

      workspace = {
        checkThirdParty = false,

        -- Make Neovim's vim API available to LuaLS
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    },
  },
}
