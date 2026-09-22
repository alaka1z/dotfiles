local atom = require("snippets.atom")

local M = {}

function M.previous(text)
  local finish = #text
  local start = finish + 1

  while start > 1 do
    local match = atom.previous(text:sub(1, start - 1))

    if not match then
      break
    end

    start = start - #match
  end

  if start == finish + 1 then
    return nil
  end

  return text:sub(start, finish)
end

return M
