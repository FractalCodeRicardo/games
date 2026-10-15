local constants = require("constants")
local game = require("game")
function _init()
  State = {
    game = game.new()
  }
end

function _config()
  return  {
    game_id = "usagi.tetris",
    game_height = constants.screen_height(),
    game_width = constants.screen_width()
  }
end

function _update(dt)
  State.game:update(dt)
end

function _draw(dt)
  gfx.clear(gfx.COLOR_DARK_BLUE)
  State.game:draw()
end
