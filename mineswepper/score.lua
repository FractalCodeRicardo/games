local Constants = require("constants")
local board_size = Constants.CELL_SIZE * Constants.BOARD_SIZE
local start = board_size + 5;

local Score = {}
Score.__index = Score;

function Score:new()
  local instance = setmetatable({}, Score)
  instance.totalSquares = 100
  instance.openSquares = 70
  instance.totalMines = 100
  instance.openMines = 40
  return instance
end

function Score:draw()
  gfx.rect_fill(start, 5, Constants.SCORE_SIZE - 10, board_size - 10, gfx.COLOR_BLACK)
  gfx.rect(start, 5, Constants.SCORE_SIZE - 10, board_size - 10, gfx.COLOR_PEACH)

  gfx.text("SCORE <(^_^)> ", board_size +  10, 10, gfx.COLOR_WHITE)

  self:draw_bar(40, self.openSquares, self.totalSquares, "squares")
  self:draw_bar(80, self.openMines, self.totalMines, "Mines")
end

function Score:draw_bar(y, progress, total, title)

  local discovered = progress / total
  local discoveredText = string.format("%i/%i %s", self.openSquares, self.totalSquares, title)

  gfx.text(discoveredText, board_size +  10, y, gfx.COLOR_WHITE)

  local w = Constants.SCORE_SIZE - 30;
  gfx.rect(start + 5, y + 15, w, 15, gfx.COLOR_PEACH)

  local pw = w * discovered;
  gfx.rect_fill(start + 6, y + 16, pw, 13, gfx.COLOR_GREEN)
end

function Score:update_score()

end

return Score
