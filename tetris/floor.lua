local constants = require("constants")
local draw = require("draw")
local M = {}
M.__index = M


function M.new()
  local floor = {}
  setmetatable(floor, M)
  
  floor.squares = {}
  return floor
end

function M.get_bottom_square(squares)
  local bottom = squares[1]
  for _, s in ipairs(squares) do
    if bottom.y < s.y then
      bottom = s
    end
  end

  return bottom
end


function M:is_crash(squares)
  if #squares == 0 then
    return false
  end

  local bottom = self.get_bottom_square(squares)

  if bottom.y == constants.BOARD_SIZE.h -1 then
    return true
  end

  for _, s in ipairs(self.squares) do

    local crash = bottom.y == 
      s.y - 1 and bottom.x == s.x

    if crash then
      return true
    end
  end

  return false
end

function M:add_squares(squares)
  for _, s in ipairs(squares) do
    table.insert(self.squares, s)
  end
end

function M:remove_line(y)
  local i= #self.squares

  while (i>= 1 ) do
    local s = self.squares[i]
    
    if s.y == y then
      table.remove(self.squares, i)
    end

    i -= 1
  end
end

function M:move_bellow(y)
  for _, s in ipairs(self.squares) do
    if s.y < y then
      s.y += 1
    end
  end
end

function M:remove_complete_lines()
  local lines = self:lines_to_remove()

  for _, line in ipairs(lines) do
    self:remove_line(line)
    self:move_bellow(line)
  end
end

function M:lines_to_remove()
  local count = {}
  local lines = {}

  for _, s in ipairs(self.squares) do
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

function M:draw()
  for _, s in pairs(self.squares) do
    draw.square(s.x, s.y, gfx.COLOR_BROWN)
  end

end


return M
