local constants = require("constants")
local M = {}
M.__index = M


function M.new(config)
  local score = {}
  setmetatable(score, M)

  score.value = 0
  score.config = config

  return score
end


function M:update_score(count)
  self.value += count
end

function M:draw()
  local x = self.config.pos.x
  local y = self.config.pos.y
    + (constants.BOARD_SIZE.h + 1) * constants.SQUARE_SIZE + 5

  gfx.text("SCORE: " .. self.value, x, y, gfx.COLOR_WHITE)
end

return M
