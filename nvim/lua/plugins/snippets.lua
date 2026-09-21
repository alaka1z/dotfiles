return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    event = "InsertEnter",

    config = function()
      local ls = require("luasnip")
      local map = vim.keymap.set
      local function in_mathzone()
        return vim.fn["vimtex#syntax#in_mathzone"]() == 1
      end

      ls.config.setup({
        enable_autosnippets = true,
        update_events = "TextChanged,TextChangedI",
      })

      local function load_snippets()
        for _, module in ipairs({
          "snippets.atom",
          "snippets.helpers",
          "snippets.build",
          "snippets.tex",
          "snippets.math",
          "snippets.advanced",
        }) do
          package.loaded[module] = nil
        end

        local build = require("snippets.build")

        ls.add_snippets("tex", build.build(require("snippets.tex")), {
          key = "tex",
        })

        ls.add_snippets("tex", build.build(require("snippets.math"), {
          condition = in_mathzone,
        }), {
          key = "math",
        })

        ls.add_snippets("tex", require("snippets.advanced"), {
          key = "advanced",
        })
      end

      load_snippets()

      vim.api.nvim_create_user_command("SnippetsReload", load_snippets, {})

      -- ls.add_snippets("tex", build.build(require("snippets.tex")), {
      --   key = "tex",
      -- })
      --
      -- ls.add_snippets("tex", build.build(require("snippets.math"), {
      --   condition = in_mathzone,
      -- }), {
      --   key = "math",
      -- })
      --
      -- ls.add_snippets("tex", require("snippets.advanced"), {
      --   key = "advanced",
      -- })

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
