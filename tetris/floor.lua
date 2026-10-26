local constants = require("constants")
local draw = require("draw")
local M = {}
M.__index = M


function M.new(config)
  local floor = {}
  setmetatable(floor, M)
 
  floor.config =config 
  floor.squares = {}
  return floor
end

function M:is_crash(squares)
  if #squares == 0 then
    return false
  end

  return self:bottom_distance(squares) == 0
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
  local count = #lines

  for _, line in ipairs(lines) do
    self:remove_line(line)
    self:move_bellow(line)
  end

  return count
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

function M:is_game_over()
  local count = {}

  for _, s in ipairs(self.squares) do
    if count[s.x] == nil then
      count[s.x] = 1
    else
      count[s.x] += 1
    end

    if count[s.x] == constants.BOARD_SIZE.h then
      return true
    end
  end

  return false
end

function M:square_distance(square)
  local distance = constants.BOARD_SIZE.h - square.y - 1

  for _, s in ipairs(self.squares) do
    if s.x == square.x and s.y > square.y then
      local d = s.y - square.y - 1
      if d < distance then
        distance = d
      end
    end
  end

  return distance
end

function M:bottom_distance(squares)
  local distance = constants.BOARD_SIZE.h

  for _, s in ipairs(squares) do
    local d = self:square_distance(s)
    if d < distance then
      distance = d
    end
  end

  return distance
end

function M:draw()
  local b_pos = self.config.pos
  for _, s in pairs(self.squares) do
    local pos = { x = s.x, y = s.y }
    draw.square(b_pos, pos, gfx.COLOR_BROWN)
  end

end


return M
