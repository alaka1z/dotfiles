local helpers = require("snippets.helpers")

local M = {}

local function add(snippets, definitions, make_snippet, opts)
  for _, definition in ipairs(definitions or {}) do
    snippets[#snippets + 1] =
      make_snippet(definition[1], definition[2], opts)
  end
end

function M.build(definitions, opts)
  local snippets = {}

  add(snippets, definitions.normal, helpers.normal, opts)
  add(snippets, definitions.auto, helpers.auto, opts)
  add(snippets, definitions.inword_auto, helpers.inword_auto, opts)
  add(snippets, definitions.regex_auto, helpers.regex_auto, opts)
  add(snippets, definitions.postfix_auto, helpers.postfix_auto, opts)

  return snippets
end

return M
