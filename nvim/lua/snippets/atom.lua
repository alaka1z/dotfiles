local M = {}

local function matching_open(text, close)
  local depth = 0

  for pos = close, 1, -1 do
    local char = text:sub(pos, pos)

    if char == "}" then
      depth = depth + 1
    elseif char == "{" then
      depth = depth - 1

      if depth == 0 then
        return pos
      end
    end
  end
end

local function consume_script(text, pos)
  if text:sub(pos, pos) == "}" then
    local open = matching_open(text, pos)

    if open and (text:sub(open - 1, open - 1) == "^"
        or text:sub(open - 1, open - 1) == "_") then
      return open - 2
    end
  elseif pos >= 2 then
    local marker = text:sub(pos - 1, pos - 1)

    if marker == "^" or marker == "_" then
      return pos - 2
    end
  end
end

function M.previous(text)
  local finish = #text
  local pos = finish

  -- Consume trailing superscripts/subscripts
  while pos > 0 do
    local next_pos = consume_script(text, pos)

    if not next_pos then
      break
    end

    pos = next_pos
  end

  if pos < 1 then
    return nil
  end

  local start
  local char = text:sub(pos, pos)

  -- Explicit {...} group
  if char == "}" then
    start = matching_open(text, pos)

  -- Ordinary identifier / LaTeX control sequence
  elseif char:match("[%w%.%-]") then
    start = pos

    while start > 1
        and text:sub(start - 1, start - 1):match("[%w%.%-]") do
      start = start - 1
    end

    -- Include the leading backslash of \alpha, \beta, etc.
    if start > 1
        and text:sub(start - 1, start - 1) == "\\"
        and text:sub(start, pos):match("^%a+$") then
      start = start - 1
    end

  else
    start = pos
  end

  return text:sub(start, finish)
end

return M
