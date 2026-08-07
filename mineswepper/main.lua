local Constants = require("constants")
local Board = require("board")
local SIZE = Constants.SIZE;
local CELL_SIZE =Constants.CELL_SIZE;
local MINES = Constants.MINES;


function _config()
  ---@type Usagi.Config
  return {
    name = "Game",
    game_id = "com.usagiengine.YOURGAMENAME",
    game_height = SIZE * CELL_SIZE,
    game_width = SIZE * CELL_SIZE
  }
end

function _init()
  local board = Board:new()
  State = {
    game_over = false,
    board = board
  }
end


function draw_game_over()
  gfx.text_ex("Game Over",
    usagi.GAME_W / 2 - 180,
    usagi.GAME_H / 2 - 100,
    8,
    0,
    gfx.COLOR_TRUE_WHITE, 1)
end

function _update(dt)
  if input.mouse_pressed(input.MOUSE_LEFT) then
    local mx, my = input.mouse()
    State.board:open(mx, my)
  end
end

function _draw(dt)
  gfx.clear(gfx.COLOR_DARK_PURPLE)

  if State.game_over then
    draw_game_over()
  end
  State.board:draw_board()
end
