local constants = require("constants")
local M = {}
M.__index = M

local TEXT = "GAME OVER"

function M.new(config)
  local game_over = {}
  setmetatable(game_over, M)

  game_over.config = config

  return game_over
end

function M:draw()
  local size = constants.SQUARE_SIZE
  local board_w = constants.BOARD_SIZE.w * size
  local board_h = constants.BOARD_SIZE.h * size
  local w, h = usagi.measure_text(TEXT)

  local x = self.config.pos.x + (board_w - w) / 2
  local y = self.config.pos.y + (board_h - h) / 2

  gfx.text(TEXT, x, y, gfx.COLOR_RED)
end

return M
