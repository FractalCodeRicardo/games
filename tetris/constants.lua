local M = {}

M.SQUARE_SIZE = 20
M.MOVE_TIME = 0.5

M.BOARD_SIZE = {
  w = 8,
  h = 16
}

function M.screen_width() 
  return M.BOARD_SIZE.w * M.SQUARE_SIZE
end

function M.screen_height()
  return M.BOARD_SIZE.h * M.SQUARE_SIZE
end

return M
