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

  elseif char:match("%a") then
    local command_start = pos

    while command_start > 1
      and text:sub(command_start - 1, command_start - 1):match("%a") do
      command_start = command_start - 1
    end

    -- A control sequence like \alpha is one atom
    if command_start > 1
      and text:sub(command_start - 1, command_start - 1) == "\\" then
      start = command_start - 1

      -- An ordinary variable is only one letter
    else
      start = pos
    end

  elseif char:match("%d") then
    start = pos

    -- Keep multi-digit numbers together
    while start > 1
      and text:sub(start - 1, start - 1):match("%d") do
      start = start - 1
    end

  else
    return nil
  end

  return text:sub(start, finish)
end

return M
