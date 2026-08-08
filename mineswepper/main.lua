local Constants = require("constants")
local Board = require("board")
local Cat = require("cat")
local Footer = require("footer")
local Score = require("score")

local SIZE = Constants.BOARD_SIZE;
local CELL_SIZE = Constants.CELL_SIZE;
local MINES = Constants.MINES;


function _config()
  ---@type Usagi.Config
  return {
    name = "Game",
    game_id = "com.usagiengine.mineswepper",
    game_height = Constants.get_screen_height(),
    game_width = Constants.get_screen_width(),
    sprite_size = Constants.SPRITE_SIZE
  }
end

function _init()
  local board = Board:new()
  local cat = Cat:new()

  State = {
    game_over = false,
    cat = cat,
    board = board,
    footer = Footer:new(),
    score = Score:new()
  }

  -- music.play_ex("music", 0.5, 1.0, 1.0, true)
end

local function draw_game_over()
  gfx.text_ex("Game Over",
    usagi.GAME_W / 2 - 180,
    usagi.GAME_H / 2 - 100,
    8,
    0,
    gfx.COLOR_TRUE_WHITE, 1)
end

function update_game(dt)
  local board = State.board;
  local cat = State.cat;
  local footer = State.footer;

  if input.key_pressed(input.KEY_SPACE) then
    board:open(cat.x, cat.y)
  end

  cat:update(dt)
  board:update(dt)
end

function _update(dt)
  update_game(dt)
end

function draw_game()
  if State.game_over then
    draw_game_over()
  end
  State.board:draw_board()
  State.cat:draw()
  State.footer:draw()
  State.score:draw()
end

function _draw(dt)
  gfx.clear(gfx.COLOR_DARK_PURPLE)
  draw_game()
end
