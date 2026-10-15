local constants = require("constants")
local pieces = require("pieces")

local M = {}
M.__index = M

function M.new()
  local squares = M.random_squares()
  local piece = {}
  piece = setmetatable(piece, M)
  piece.squares = squares
  piece.color = M.random_color()
  piece.pos = { x = 0, y = 0}
  return piece
end

function M.random_squares()
  return pieces.random()
end

function M.random_color()
  local colors = {
    gfx.COLOR_GREEN,
    gfx.COLOR_RED,
    gfx.COLOR_YELLOW,
    gfx.COLOR_BLUE
  }
  return colors[math.random(#colors)]
end

function M:rotate()
  local rotated_indexes = {
    7,4,1,
    8,5,2,
    9,6,3,
  }

  local rotated_squares = {}
  for i = 1, #rotated_indexes do
    local rindex = rotated_indexes[i]
    rotated_squares[i] = self.squares[rindex]
  end

  self.squares = rotated_squares
end

function M:each_square(callback)
  for i, s in pairs(self.squares) do
    local ci = i - 1
    local sy = math.floor(ci / 3)
    local sx = i - (sy * 3) 

    local x = self.pos.x + sx
    local y = self.pos.y + sy

    if s == 1 then
      callback(x, y)
    end
  end
end

function M:square_positions()
  local positions = {}
  self:each_square(function(x, y)
    table.insert(positions, {x = x, y = y})
  end)
  return positions
end

function M:draw(dt)
  self:each_square(function(x, y)

    gfx.rect_fill(
      x * constants.SQUARE_SIZE,
      y * constants.SQUARE_SIZE,
      constants.SQUARE_SIZE,
      constants.SQUARE_SIZE,
      self.color
    )

    gfx.rect_ex(
      x * constants.SQUARE_SIZE,
      y * constants.SQUARE_SIZE,
      constants.SQUARE_SIZE,
      constants.SQUARE_SIZE,
      0.5,
      gfx.COLOR_DARK_GRAY
    )
  end)
end

function M:update(dt)
end

function M:move_to_direction(x, y)
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

return M
