return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    event = "InsertEnter",

    config = function()
      local ls = require("luasnip")
      local types = require("luasnip.util.types")
      local map = vim.keymap.set
      local function in_mathzone()
        return vim.fn["vimtex#syntax#in_mathzone"]() == 1
      end

      ls.config.setup({
        enable_autosnippets = true,
        store_selection_keys = "<Tab>",
        update_events = "TextChanged,TextChangedI",

        keep_roots = false,
        link_roots = false,
        link_children = true,
        exit_roots = true,

        region_check_events = { "CursorMoved", "CursorMovedI" },
        delete_check_events = { "TextChanged", "TextChangedI" },

        ext_opts = {
          [types.insertNode] = {
            active = {
              virt_text = { { "▸", "Comment" } },
              virt_text_pos = "inline",
            },
            passive = {
              virt_text = { { "·", "Comment" } },
              virt_text_pos = "inline",
            },
          },
          [types.exitNode] = {
            unvisited = {
              virt_text = { { "·", "Comment" } },
              virt_text_pos = "inline",
            },
          },
        },
      })

      local function load_snippets()
        for _, module in ipairs({
          "snippets.atom",
          "snippets.term",
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

      map("i", "<End>", function()
        ls.session.config.enable_autosnippets =
          not ls.session.config.enable_autosnippets

        ls.config._setup()

        vim.notify(
          ls.session.config.enable_autosnippets
            and "Snippets on"
            or "Snippets off"
        )
      end, { silent = true })

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

      map("x", "<S-Tab>", function()
        vim.b.snippet_selection = vim.fn.getregion(
          vim.fn.getpos("v"),
          vim.fn.getpos("."),
          { type = vim.fn.mode() }
        )

        vim.cmd("normal! y")
      end, { silent = true })
    end,
  },
}
