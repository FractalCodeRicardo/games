local Constants = require("constants")
local Board = require("board")
local Cat = require("cat")
local Footer = require("footer")
local Score = require("score")
local Menu = require("menu")
local AI = require("ai")

local SIZE = Constants.BOARD_SIZE;
local CELL_SIZE = Constants.CELL_SIZE;
local MINES = Constants.MINES;

local states = {
  menu = "menu",
  playing = "playing"
}

local modes = {
  solve_problems = "solve_problems",
  vsAI = "vsAI"
}

local turns = {
  cat = "cat",
  ia = "ia"
}


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
  local y = math.floor(SIZE / 2)
  local x = math.floor(SIZE / 2)
  local board = Board:new()
  local cat = Cat:new("me", x - 1, y, 1)
  local ia = Cat:new("ia", x + 1, y, 9)

  Menu.on_start = function()
    State.state = "game"
  end

  State = {
    game_over = false,
    cat = cat,
    ia = ia,
    current_turn = turns.cat,
    board = board,
    footer = Footer:new(),
    score = Score:new(),
    menu = Menu,
    state = states.menu,
    mode = modes.solve_problems
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

local function refresh_score()
  local score = State.board:get_score()
  State.score:update_score(score)
end


local function uncover_cell()
  local footer = State.footer
  local board = State.board
  local cat = State.board

  if State.mode == modes.solve_problems then
    footer:show_problem(function(success)
      if success then
        board:open(cat.x, cat.y)
        refresh_score()
      end
    end)

    return
  end

  board:open(cat.x, cat.y)
  refresh_score()
end

local function change_turn()
  if State.current_turn == turns.cat then
    State.current_turn = turns.ia
  else
    State.current_turn = turns.cat
  end
end

local function AI_move()
  local move = AI.get_move(State.board.cells)
  local board = State.board
  local score = State.score

  if move == nil then
    error("Error getting the move")
    return
  end

  print("Move " .. usagi.to_json(move))

  if move.move == "uncover" then
    board:open(move.x, move.y)
    change_turn()
    return
  end

  if move.move == "flag" then
    local win = board:add_flag(move.x, move.y)
    if win then
      score:increase_flags(0, 1)
    else
      change_turn()
    end
  end

  refresh_score()
end


local function update_game(dt)
  local board = State.board;
  local cat = State.cat;
  local footer = State.footer;
  local score = State.score;

  if State.current_turn == turns.cat then
    if input.key_pressed(input.KEY_Q) then
      uncover_cell()
      change_turn()
    end

    if input.key_pressed(input.KEY_W) then
      local win = board:add_flag(cat.x, cat.y)
      refresh_score()

      if win then
        State.score:increase_flags(1, 0)
      else
        change_turn()
      end
    end
  end

  if not footer:user_is_solving() then
    cat:update(dt)
  end
  board:update(dt)
  footer:update(dt)
  score:update(dt)

  if State.current_turn == turns.ia then
    AI_move()
  end
end

local function update_menu()
  State.menu.update()
end

function _update(dt)
  if State.state == states.menu then
    update_menu()
  else
    update_game(dt)
  end
end

local function draw_game()
  if State.game_over then
    draw_game_over()
  end
  State.board:draw_board()
  State.cat:draw()
  State.footer:draw()
  State.score:draw()
end

local function draw_menu()
  State.menu.draw()
end

function _draw(dt)
  gfx.clear(gfx.COLOR_DARK_PURPLE)

  if State.state == "menu" then
    draw_menu()
  else
    draw_game()
  end
end
