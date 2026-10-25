local constants = require("constants")
local M = {}

function M.square(board_pos, pos, color)
  local size = constants.SQUARE_SIZE;
  local px = board_pos.x
  local py = board_pos.y

  gfx.rect_fill(
    pos.x * size + px,
    pos.y * size + py,
    size,
    size,
    color
  )

  gfx.rect_ex(
    pos.x * size + px,
    pos.y * size + py,
    size,
    size,
    0.5,
    gfx.COLOR_WHITE
  )
end

function M.rect(board_pos, p1, p2, color)
  for x = p1.x, p2.x do
    local top = { x = x, y = p1.y }
    local bottom = { x = x, y = p2.y }

    M.square(board_pos, top, color)
    M.square(board_pos, bottom, color)
  end

  for y = p1.y, p2.y do
    local left = { x = p1.x, y = y }
    local right = { x = p2.x, y = y }

    M.square(board_pos, left, color)
    M.square(board_pos, right, color)
  end
end

return M
