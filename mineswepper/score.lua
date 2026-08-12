local Constants = require("constants")
local board_size = Constants.CELL_SIZE * Constants.BOARD_SIZE
local start = board_size + 5;

local Score = {}
Score.__index = Score;

function Score:new()
  local instance = setmetatable({}, Score)
  instance.totalSquares = 0
  instance.openSquares = 0
  instance.totalMines = 0
  instance.openMines = 0
  instance.seconds = Constants.SECONDS
  instance.cat_flags = 0
  instance.ia_flags = 0
  return instance
end

function Score:draw()
  gfx.rect_fill(start, 5, Constants.SCORE_SIZE - 10, board_size - 10, gfx.COLOR_BLACK)
  gfx.rect(start, 5, Constants.SCORE_SIZE - 10, board_size - 10, gfx.COLOR_PEACH)

  gfx.text("SCORE <(^_^)> ", board_size + 10, 10, gfx.COLOR_WHITE)

  self:draw_bar(40, self.openSquares, self.totalSquares, "squares")
  self:draw_bar(80, self.openMines, self.totalMines, "Mines")

  self:draw_seconds()
end

function Score:draw_bar(y, progress, total, title)
  local discovered = progress / total
  local discoveredText = string.format("%i/%i %s", progress, total, title)

  gfx.text(discoveredText, board_size + 10, y, gfx.COLOR_WHITE)

  local w = Constants.SCORE_SIZE - 30;
  gfx.rect(start + 5, y + 15, w, 15, gfx.COLOR_PEACH)

  local pw = w * discovered;
  gfx.rect_fill(start + 6, y + 16, pw, 13, gfx.COLOR_GREEN)
end

function Score:draw_seconds()
  local minutes = math.floor(self.seconds / 60)
  local seconds = self.seconds - minutes * 60

  minutes = math.floor(minutes)
  seconds = math.floor(seconds)

  minutes = math.max(0, minutes)
  seconds = math.max(0, seconds)

  local text = string.format("%02d:%02d", minutes, seconds)

  gfx.text_ex(text, start + 15,
    board_size - 50,
    2,
    0,
    gfx.COLOR_GREEN,
    1
  )
end

function Score:update_score(score)
  self.totalSquares = score.totalSquares
  self.openSquares = score.openSquares
  self.totalMines = score.totalMines
  self.openMines = score.openMines
end

function Score:update(dt)
  self.seconds -= dt
end

function Score:increase_flags(cat, ia)
  self.cat_flags += cat
  self.ia_flags = ia
end

return Score
