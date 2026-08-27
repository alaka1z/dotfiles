return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    event = "InsertEnter",

    config = function()
      local ls = require("luasnip")
      local map = vim.keymap.set
      local snippet_path = vim.fn.stdpath("config") .. "/snippets"

      -- Use VimTeX to detect whether the cursor is currently inside math
      local function in_mathzone()
        return vim.fn["vimtex#syntax#in_mathzone"]() == 1
      end

      ls.config.setup({
        enable_autosnippets = true,

        -- Expose tex_math snippets only while inside a VimTeX math zone
        ft_func = function()
          local ft = vim.bo.filetype

          if ft == "tex" and in_mathzone() then
            return { "tex", "tex_math" }
          end

          return { ft }
        end,

        -- Load tex_math with TeX buffers so it is ready when ft_func activates it
        load_ft_func = function(bufnr)
          local ft = vim.bo[bufnr].filetype

          if ft == "tex" then
            return { "tex", "tex_math" }
          end

          return { ft }
        end,
      })

      -- Use SnipMate for ordinary snippets and Lua for dynamic snippets
      require("luasnip.loaders.from_snipmate").lazy_load({
        paths = snippet_path .. "/snipmate",
      })

      require("luasnip.loaders.from_lua").lazy_load({
        paths = snippet_path .. "/lua",
      })

      -- Expand snippets and move forward through their fields
      map({ "i", "s" }, "<Tab>", function()
        if ls.expand_or_locally_jumpable() then
          ls.expand_or_jump()
        else
          vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "n", false)
        end
      end, { silent = true })

      -- Move backward through snippet fields
      map({ "i", "s" }, "<S-Tab>", function()
        if ls.locally_jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true })
    end,
  },
}
