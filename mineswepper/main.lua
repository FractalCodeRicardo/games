local Constants = require("constants")
local Board = require("board")
local Cat = require("cat")
local Problem = require("problem")

local SIZE = Constants.SIZE;
local CELL_SIZE = Constants.CELL_SIZE;
local MINES = Constants.MINES;


function _config()
  ---@type Usagi.Config
  return {
    name = "Game",
    game_id = "com.usagiengine.YOURGAMENAME",
    game_height = SIZE * CELL_SIZE,
    game_width = SIZE * CELL_SIZE,
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
    state = "problem",
    problem = Problem:new()
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

  if input.key_pressed(input.KEY_SPACE) then
    board:open(cat.x, cat.y)
  end

  cat:update(dt)
  board:update(dt)
end

function update_problem(dt)
  State.problem:update()
end

function _update(dt)
  if State.state == "game" then
    update_game(dt)
  else
    update_problem(dt)
  end
end

function draw_game()
  if State.game_over then
    draw_game_over()
  end
  State.board:draw_board()
  State.cat:draw()
end

function draw_problem()
  State.problem:draw()
end

function _draw(dt)
  gfx.clear(gfx.COLOR_DARK_PURPLE)

  if State.state == "game" then
    draw_game()
  else
    draw_problem()
  end
end
