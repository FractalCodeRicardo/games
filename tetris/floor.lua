local constants = require("constants")

local M = {}
M.__index = M

function M:new()
  local floor = {}
  floor = setmetatable(floor, M)
  floor.squares = {}
  return floor
end

function M:add_piece(squares)
  for i = 1, #squares do
    table.insert(self.squares, squares[i])
  end
end

function M.get_bottom_square(squares)
  local bottom = squares[1]
  for _, s in pairs(squares) do
    if bottom.y < s.y then
      bottom = s
    end
  end
  return bottom
end

function M:get_top_floor(x)
  local top_floor_y = nil

  for _, s in pairs(self.squares) do
    if s.x ~= x then
      goto continue
    end

    if top_floor_y == nil then
      top_floor_y = s.y
      goto continue
    end

    if s.y < top_floor_y then
      top_floor_y = s.y
    end

    ::continue::
  end

  return top_floor_y
end

function M:bottom_distance(squares)
  local bottom_piece = self.get_bottom_square(squares)
  local top_floor_y = self:get_top_floor(bottom_piece.x)
  
  if top_floor_y == nil then
    return constants.BOARD_SIZE.h - bottom_piece.y - 1 
  end
  
  return top_floor_y - bottom_piece.y - 1
end

function M:crash(squares)
  if #squares == 0  then
    return
  end
  local bottom = self.get_bottom_square(squares)
  
  local crash_bottom = bottom.y == constants.BOARD_SIZE.h - 1
  if crash_bottom then
    return true
  end

  for _, s in pairs(self.squares) do
    local crash_next_move = 
        s.x == bottom.x and
        bottom.y + 1 == s.y 

    if crash_next_move then
      return true
    end
  end

  return false
end

function M:draw()
  local size = constants.SQUARE_SIZE;
  for _, s in pairs(self.squares) do
    gfx.rect_fill(
      s.x * size,
      s.y * size,
      size,
      size,
      gfx.COLOR_BROWN
    )

    gfx.rect_ex(
      s.x * size,
      s.y * size,
      size,
      size,
      0.5,
      gfx.COLOR_DARK_GRAY
    )
  end
end

function M:move_bellow(since_y)
  for _, s in pairs(self.squares) do
    if since_y > s.y then
      s.y += 1
    end
  end
end

function M:remove_line(y)
  local i = #self.squares

  while (i >= 1) do
    local s = self.squares[i]
    if y == s.y then
      table.remove(self.squares, i)
    end
    i -= 1
  end
end

function M:remove_complete_lines()
  local lines = self:lines_to_remove()

  for i,line in ipairs(lines) do
    self:remove_line(line)
    self:move_bellow(line)
  end
end

function M:lines_to_remove()
  local lines = {}
  local count = {}

  for _, s in pairs(self.squares) do
    if count[s.y] == nil then
      count[s.y] = 1
    else
      count[s.y] +=1
    end

    if count[s.y] == constants.BOARD_SIZE.w then
      table.insert(lines, s.y)
    end
  end

  table.sort(lines)
  return lines
end

return M
