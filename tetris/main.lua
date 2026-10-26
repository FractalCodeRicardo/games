local constants = require("constants")
local game = require("game")
local openai = require("openai")
local claude = require("claude")
local http = require("http")

function _init()
  local board_w = constants.board_width()
  local board_h = constants.board_height()
  local openai = game.new({ 
    pos = { x =30 + board_w * 0, y = 30 },
    name = "Open AI"
  }, openai:new())

  local claude = game.new({ 
    name = "Claude",
    pos = {x = 30+ board_w * 1, y = 30 } 
  }, claude:new())

  local keyboard =game.new({ 
    name = "Human",
    pos = { x = 30 +  board_w * 2, y = 30 }
  }) 

  State = {
      games = {
        keyboard,
        openai,
        claude
      }
  }
end

function _config()
  return {
    game_id = "usagi.tetris",
    game_height = constants.board_height(),
    game_width = constants.board_width() * 3
  }
end

function _update(dt)
  http.update()
  for _, g in ipairs(State.games) do
    g:update(dt)
  end
end

function _draw(dt)
  gfx.clear(gfx.COLOR_DARK_BLUE)

  for _, g in ipairs(State.games) do
    g:draw(dt)
  end
end
