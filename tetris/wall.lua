local constants = require("constants")
local draw = require("draw")
local M = {}
M.__index = M


function M.new()
  local wall = {}
  setmetatable(wall, M)
  
  return wall
end

function M:draw()
  local size = constants.SQUARE_SIZE
  local w = constants.BOARD_SIZE.w 
  local h = constants.BOARD_SIZE.h 

  local p1 = { x = -1, y = 0}
  local p2 = { x = w , y = h }
  local color = gfx.COLOR_LIGHT_GRAY

  draw.rect(p1, p2, color)

end

return M
