local constants = require("constants")

local M = {}
M.__index = M

function M.positions_to_dict(positions)
  local dict = {}

  for _, pos in ipairs(positions) do
    dict[pos.x .. "," .. pos.y] = pos
  end

  return dict
end

function M.get_character(x, y, pieces, floor)
  local w = constants.BOARD_SIZE.w
  local h = constants.BOARD_SIZE.h
  local is_wall = (y == -1 or y == h or x == -1 or x == w)

  if is_wall then
    return "x"
  end

  local key = x .. "," .. y

  if floor[key] ~= nil then
    return "x"
  end

  if pieces[key] ~= nil then
    return "*"
  end

  return " "
end

function M.board_to_string(game)
  local w = constants.BOARD_SIZE.w
  local h = constants.BOARD_SIZE.h
  local board = ""
  local pieces = M.positions_to_dict(game.piece:square_positions())
  local floor = M.positions_to_dict(game.floor.squares)

  for y = -1, h do
    for x = -1, w do
      local char = M.get_character(x, y, pieces, floor)
      board = board .. char
    end

    board = board .. "\n"
  end

  return board
end

return M
