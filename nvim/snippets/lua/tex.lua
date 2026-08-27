local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Normal snippets
  s("bf", {
    t("\\textbf{"),
    i(1),
    t("}"),
  }),
}, {
  -- Autosnippets
  s("mk", {
    t("$"),
    i(1),
    t("$"),
  }),
}
