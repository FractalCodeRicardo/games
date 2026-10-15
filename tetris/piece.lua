local constants = require("constants")
local pieces = require("pieces")

local M = {}
M.__index = M


function M.new()
  local piece = {}
  setmetatable(piece, M)
  piece.squares = M.random_squares()
  piece.color = M.random_colors()
  piece.pos = {x = 0, y =0}
  return piece
end

function M.random_colors()
 local colors = {
   gfx.COLOR_GREEN,
   gfx.COLOR_YELLOW,
   gfx.COLOR_BLUE,
   gfx.COLOR_ORANGE,
   gfx.COLOR_PINK,
   gfx.COLOR_RED,
 }

 return colors[math.random(#colors)]
end

function M.random_squares()
  return pieces.random()
end

function M:rotate()
  local rotated_indexes = {
    7,4,1,
    8,5,2,
    9,6,3,
  }

  local rotated_squares = {}

  for i, rindex in ipairs(rotated_indexes) do
    rotated_squares[i] = self.squares[rindex]
  end

  self.squares = rotated_squares
end

function M:each_square(callback)
  for index, s in pairs(self.squares) do
    local i = index - 1
    local sy = math.floor(i / 3) 
    local sx = i - (sy * 3)

    if s == 1 then
      callback(self.pos.x + sx, self.pos.y + sy)
    end

  end
end

function M:draw()
  local size = constants.SQUARE_SIZE
  self:each_square(function(x, y)

    gfx.rect_fill(
      x * size,
      y * size,
      size,
      size,
      self.color
    )


    gfx.rect_ex(
      x * size,
      y * size,
      size,
      size,
      0.5,
     gfx.COLOR_WHITE
    )
  end)
end
  
function M:move_to_direction(x,y)
  self.pos.x += x
  self.pos.y += y
end

function M:move()
  self:move_to_direction(0, 1)
end

function M:right()
  self:move_to_direction(1, 0)
end

function M:left()
  self:move_to_direction(-1, 0)
end


function M:square_positions()
  local positions = {}

  self:each_square(function (x, y)
    table.insert(positions, {x = x, y = y})
  end)

  return positions
end














return M
