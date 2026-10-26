local M = {}

M.SQUARE_SIZE = 15
M.MOVE_TIME = 3
M.MOVE_AI_TIME = 0.4

M.BOARD_SIZE = {
  w = 8,
  h = 16
}

M.BOARD_POS = {
  x = M.SQUARE_SIZE + 5,
  y = M.SQUARE_SIZE + 5
}

function M.screen_height()
  local margin = M.SQUARE_SIZE * 5;
  return M.BOARD_SIZE.h * M.SQUARE_SIZE + margin; -- include the border
end

function M.screen_width()
  local margin = M.SQUARE_SIZE * 5;
  return M.BOARD_SIZE.w * M.SQUARE_SIZE + margin;
end


return M
