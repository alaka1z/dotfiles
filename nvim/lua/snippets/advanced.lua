local ls = require("luasnip")

local s, sn = ls.snippet, ls.snippet_node
local t, i, d, f = ls.text_node, ls.insert_node, ls.dynamic_node, ls.function_node

local function in_mathzone()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local function matrix(_, parent)
  local rows = tonumber(parent.snippet.captures[1])
  local cols = tonumber(parent.snippet.captures[2])

  local nodes = {}
  local index = 1

  for row = 1, rows do
    for col = 1, cols do
      nodes[#nodes + 1] = i(index)
      index = index + 1

      if col < cols then
        nodes[#nodes + 1] = t(" & ")
      end
    end

    if row < rows then
      nodes[#nodes + 1] = t({ " \\\\", "  " })
    end
  end

  return sn(nil, nodes)
end

local function mathbb_capture(_, snip)
  return "\\mathbb{" .. snip.captures[1]:upper() .. "}"
end

local function after_brace(line_to_cursor)
  return line_to_cursor:sub(-3, -3) == "{"
end

return {
  s({
    trig = "mat(%d+)(%d+)",
    trigEngine = "pattern",
    condition = in_mathzone,
  }, {
    t({ "\\begin{bmatrix}", "  " }),
    d(1, matrix, {}),
    t({ "", "\\end{bmatrix}" }),
  }),

  s({
    trig = "f([nqrcz])([nqrcz])",
    trigEngine = "pattern",
    snippetType = "autosnippet",
    condition = in_mathzone,
  }, {
    ls.function_node(function(_, snip)
      return string.format(
        "f : \\mathbb{%s} \\to \\mathbb{%s}",
        snip.captures[1]:upper(),
        snip.captures[2]:upper()
      )
    end),
  }),

  s({
    trig = "fto([nqrcz])",
    trigEngine = "pattern",
    snippetType = "autosnippet",
    condition = in_mathzone,
  }, {
    t("f : "),
    i(1),
    t(" \\to "),
    f(mathbb_capture, {}),
    t(" "),
    i(0),
  }),

  s({
    trig = "f([nqrcz])to",
    trigEngine = "pattern",
    snippetType = "autosnippet",
    condition = in_mathzone,
  }, {
    t("f : "),
    f(mathbb_capture, {}),
    t(" \\to "),
    i(0),
  }),

  -- Normal: fof → f($1)$0
  s({
    trig = "of",
    wordTrig = false,
    snippetType = "autosnippet",
    condition = function(line_to_cursor)
      return in_mathzone() and not after_brace(line_to_cursor)
    end,
  }, {
    t("("),
    i(1),
    t(")"),
    i(0),
  }),

  -- Nested: sin{of → sin{($0)}
  s({
    trig = "of",
    wordTrig = false,
    snippetType = "autosnippet",
    condition = function(line_to_cursor)
      return in_mathzone() and after_brace(line_to_cursor)
    end,
  }, {
    t("("),
    i(0),
    t(")"),
  }),
}
