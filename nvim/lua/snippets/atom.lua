local M = {}

local pairs = {
  [")"] = "(",
  ["]"] = "[",
  ["}"] = "{",
}

local function char(text, pos)
  return text:sub(pos, pos)
end

local function is_escaped(text, pos)
  local count = 0
  pos = pos - 1

  while pos >= 1 and char(text, pos) == "\\" do
    count = count + 1
    pos = pos - 1
  end

  return count % 2 == 1
end

local function matching_open(text, close)
  local close_char = char(text, close)
  local open_char = pairs[close_char]

  if not open_char then
    return nil
  end

  local depth = 0

  for pos = close, 1, -1 do
    local current = char(text, pos)

    if not is_escaped(text, pos) then
      if current == close_char then
        depth = depth + 1

      elseif current == open_char then
        depth = depth - 1

        if depth == 0 then
          return pos
        end
      end
    end
  end
end

local function control_start(text, finish)
  local pos = finish

  if char(text, pos) == "*" then
    pos = pos - 1
  end

  if pos < 1 then
    return nil
  end

  local current = char(text, pos)

  if current:match("%a") then
    local start = pos

    while start > 1 and char(text, start - 1):match("%a") do
      start = start - 1
    end

    if start > 1 and char(text, start - 1) == "\\" then
      return start - 1
    end

  elseif pos > 1 and char(text, pos - 1) == "\\" then
    return pos - 1
  end
end

local function marker_at(text, pos, name)
  local marker = "\\" .. name

  if is_escaped(text, pos)
    or text:sub(pos, pos + #marker - 1) ~= marker then
    return false
  end

  local next_char = char(text, pos + #marker)

  return next_char ~= "" and not next_char:match("%a")
end

local function right_start(text, finish)
  local delim_start
  local current = char(text, finish)

  if current:match("%a") then
    delim_start = control_start(text, finish)

  elseif finish > 1 and char(text, finish - 1) == "\\" then
    delim_start = finish - 1

  else
    delim_start = finish
  end

  if not delim_start then
    return nil
  end

  local start = delim_start - 6

  if start >= 1
    and text:sub(start, delim_start - 1) == "\\right" then
    return start
  end
end

local function matching_left(text, right)
  local depth = 1

  for pos = right - 1, 1, -1 do
    if marker_at(text, pos, "right") then
      depth = depth + 1

    elseif marker_at(text, pos, "left") then
      depth = depth - 1

      if depth == 0 then
        return pos
      end
    end
  end
end

local function escaped_brace_start(text, finish)
  if finish < 2 or text:sub(finish - 1, finish) ~= "\\}" then
    return nil
  end

  local depth = 0

  for pos = finish - 1, 1, -1 do
    local pair = text:sub(pos, pos + 1)

    if not is_escaped(text, pos) then
      if pair == "\\}" then
        depth = depth + 1

      elseif pair == "\\{" then
        depth = depth - 1

        if depth == 0 then
          return pos
        end
      end
    end
  end
end

local function argument_start(text, finish)
  local current = char(text, finish)

  if (current == "}" or current == "]")
    and not is_escaped(text, finish) then
    return matching_open(text, finish)
  end
end

local function command_with_args_start(text, finish)
  local pos = finish
  local has_args = false

  while pos > 0 do
    local start = argument_start(text, pos)

    if not start then
      break
    end

    has_args = true
    pos = start - 1
  end

  if not has_args then
    return nil
  end

  return control_start(text, pos)
end

local function number_start(text, finish)
  local start = finish

  while start > 1 and char(text, start - 1):match("%d") do
    start = start - 1
  end

  if start > 2
    and char(text, start - 1) == "."
    and char(text, start - 2):match("%d") then
    start = start - 1

    while start > 1 and char(text, start - 1):match("%d") do
      start = start - 1
    end
  end

  return start
end

local function script_marker(text, finish)
  if finish < 2 then
    return nil
  end

  local current = char(text, finish)

  if current == "}"
    and not is_escaped(text, finish) then
    local open = matching_open(text, finish)

    if open and open > 1 then
      local marker = char(text, open - 1)

      if marker == "^" or marker == "_" then
        return open - 1
      end
    end
  end

  local command = control_start(text, finish)

  if command and command > 1 then
    local marker = char(text, command - 1)

    if marker == "^" or marker == "_" then
      return command - 1
    end
  end

  local marker = char(text, finish - 1)

  if (marker == "^" or marker == "_")
    and current ~= "{"
    and current ~= "["
    and current ~= "(" then
    return finish - 1
  end
end

local scan_atom

local function callable_start(text, finish)
  if finish < 1 then
    return nil
  end

  local start, kind = scan_atom(text, finish)

  if kind == "letter"
    or kind == "command"
    or kind == "call" then
    return start
  end
end

local function scan_core(text, finish)
  local right = right_start(text, finish)

  if right then
    local left = matching_left(text, right)

    if not left then
      return nil
    end

    local callable = callable_start(text, left - 1)

    if callable then
      return callable, "call"
    end

    return left, "group"
  end

  local escaped = escaped_brace_start(text, finish)

  if escaped then
    return escaped, "group"
  end

  local current = char(text, finish)

  if current == "}" and not is_escaped(text, finish) then
    local command = command_with_args_start(text, finish)

    if command then
      return command, "command"
    end

    local open = matching_open(text, finish)

    if open then
      return open, "group"
    end

  elseif (current == ")" or current == "]")
    and not is_escaped(text, finish) then
    local open = matching_open(text, finish)

    if not open then
      return nil
    end

    local callable = callable_start(text, open - 1)

    if callable then
      return callable, "call"
    end

    return open, "group"

  elseif current:match("%a") then
    local command = control_start(text, finish)

    if command then
      return command, "command"
    end

    return finish, "letter"

  elseif current:match("%d") then
    return number_start(text, finish), "number"
  end
end

scan_atom = function(text, finish)
  local pos = finish

  while pos > 0 do
    local marker = script_marker(text, pos)

    if marker then
      pos = marker - 1

    elseif char(text, pos) == "!"
      or char(text, pos) == "'" then
      pos = pos - 1

    else
      break
    end
  end

  if pos < 1 then
    return nil
  end

  return scan_core(text, pos)
end

function M.previous(text)
  local start = scan_atom(text, #text)

  if not start then
    return nil
  end

  return text:sub(start)
end

return M
