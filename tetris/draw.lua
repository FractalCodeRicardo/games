local constants = require("constants")
local M = {}

function M.square(x, y, color)
  local size = constants.SQUARE_SIZE;
  local px = constants.BOARD_POS.x
  local py = constants.BOARD_POS.y
  gfx.rect_fill(
    x * size + px,
    y * size + py ,
    size,
    size,
    color
  )


  gfx.rect_ex(
    x * size + px,
    y * size + py,
    size,
    size,
    0.5,
    gfx.COLOR_WHITE
  )
end


function M.rect(p1, p2, color)
  for x = p1.x, p2.x do
    print(x)
    M.square(x, p1.y, color)
    M.square(x, p2.y, color)
  end

  for y = p1.y, p2.y do
    M.square(p1.x, y, color)
    M.square(p2.x, y, color)
  end
  
end

return M
