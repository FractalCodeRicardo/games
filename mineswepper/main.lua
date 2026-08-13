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
  playing = "playing",
  waiting = "waiting"
}

local modes = {
  solve_problems = "solve_problems",
  vsAI = "vsAI"
}

local turns = {
  cat = "cat",
  ai = "ai"
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
  local ai = Cat:new("ai", x + 1, y, 9)

  Menu.on_start = function()
    State.state = "game"
  end

  State = {
    game_over = false,
    cat = cat,
    ai = ai,
    current_turn = turns.cat,
    board = board,
    footer = Footer:new(),
    score = Score:new(),
    menu = Menu,
    state = states.menu,
    mode = modes.vsAI
  }

  -- music.play_ex("music", 0.5, 1.0, 1.0, true)
end

local function draw_game_over()
  gfx.text_ex("Game Over",
    usagi.GAME_W / 2 - 180,
    usagi.GAME_H / 2 - 130,
    5,
    0,
    gfx.COLOR_RED, 1)
end

local function is_waiting()
  return State.state == states.waiting
end

local function wait()
  State.state = states.waiting
end

local function resume()
  State.state = states.playing
  State.delay_time = nil
end

local function delay(miliseconds)
  State.state = states.waiting
  State.delay_time = miliseconds
end

local function handle_waiting(dt)
  if State.delay_time == nil then
    return
  end

  local new_time = State.delay_time - dt * 1000;
  if new_time < 0 then
    resume()
  else
    State.delay_time = new_time
  end
end


local function refresh_score()
  local score = State.board:get_score()
  State.score:update_score(score)
end

local function uncover_cell()
  local footer = State.footer
  local board = State.board
  local cat = State.cat

  if State.mode == modes.solve_problems then
    footer:show_problem(function(success)
      if success then
        board:open(cat.x, cat.y, State.current_turn)
        refresh_score()
      end
    end)

    return
  end

  board:open(cat.x, cat.y, State.current_turn)
  refresh_score()
  delay(1000)
end

local function change_turn()
  if State.current_turn == turns.cat then
    State.current_turn = turns.ai
  else
    State.current_turn = turns.cat
  end
end

local function AI_move(onFinish)
  local cells = State.board.cells
  local ai = State.ai
  AI.get_move(cells, function(move)
    local board = State.board
    local score = State.score

    if move == nil then
      error("Error getting the move")
      return
    end

    if move.move == "uncover" then
      ai:move_to(move.x, move.y)
      board:open(move.x, move.y, State.current_turn)
      change_turn()
      onFinish()
      return
    end

    if move.move == "flag" then
      ai:move_to(move.x, move.y)
      local win = board:add_flag(move.x, move.y, State.current_turn)
      if win then
        score:increase_flags(0, 1)
      else
        change_turn()
      end
    end

    refresh_score()
    onFinish()
  end)
end

local function cat_turn()
  if State.state == states.waiting then
    return
  end

  local board = State.board
  local cat = State.cat

  if input.key_pressed(input.KEY_Q) then
    uncover_cell()
    change_turn()
  end

  if input.key_pressed(input.KEY_W) then
    local win = board:add_flag(cat.x, cat.y, State.current_turn)
    refresh_score()

    if win then
      State.score:increase_flags(1, 0)
    else
      change_turn()
    end
  end
end

local function ai_turn()
  if is_waiting() then
    return
  end

  wait()
  AI_move(function()
    resume()
  end)
end

local function evaluate_finishing()
  local board = State.board

  local winner = board:get_winner()

  if winner == nil then
    return
  end

  State.game_over = true
  State.winner = winner
end

local function update_game(dt)
  local board = State.board;
  local cat = State.cat;
  local footer = State.footer;
  local score = State.score;

  if State.current_turn == turns.cat then
    cat_turn()
  end

  if State.current_turn == turns.ai then
    ai_turn()
  end

  cat:update(dt)
  board:update(dt)
  footer:update(dt)
  score:update(dt)
  handle_waiting(dt)
  evaluate_finishing()
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
  State.board:draw_board()
  State.cat:draw()
  State.footer:draw()
  State.score:draw()
  State.ai:draw()

  if State.game_over then
    draw_game_over()
  end
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
