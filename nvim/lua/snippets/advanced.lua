local ls = require("luasnip")

local s, sn = ls.snippet, ls.snippet_node
local t, i, d = ls.text_node, ls.insert_node, ls.dynamic_node

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
}
