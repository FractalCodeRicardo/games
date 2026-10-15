local game = require("game")
local constants = require("constants")

function _init()
    State = {
        game = game.new()
    }
end


function _config()
    ---@type Usagi.Config
    return {
        name = "Tetris",
        game_id = "com.usagiengine.tetris",
        game_height = constants.screen_height(),
        game_width = constants.screen_width(),
    }
end


function _update(dt)
  State.game:update(dt)
end

function _draw(dt)
    gfx.clear(gfx.COLOR_DARK_BLUE)
    State.game:draw(dt)
end
