return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    event = "InsertEnter",

    config = function()
      local ls = require("luasnip")
      local build = require("snippets.build")
      local map = vim.keymap.set
      local function in_mathzone()
        return vim.fn["vimtex#syntax#in_mathzone"]() == 1
      end

      ls.config.setup({
        enable_autosnippets = true,
      })

      ls.add_snippets("tex", build.build(require("snippets.tex")), {
        key = "tex",
      })

      ls.add_snippets("tex", build.build(require("snippets.math"), {
        condition = in_mathzone,
      }), {
        key = "math",
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
