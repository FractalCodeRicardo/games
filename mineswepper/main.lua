local Constants = require("constants")
local Board = require("board")
local Player = require("player")
local Footer = require("footer")
local Score = require("score")
local Menu = require("menu")
local Timer = require("timer")

local SIZE = Constants.BOARD_SIZE;
local CELL_SIZE = Constants.CELL_SIZE;
local MINES = Constants.MINES;
local states = Constants.states;


local modes = {
    solve_problems = "solve_problems",
    vsAI = "vsAI"
}


function _config()
    ---@type Usagi.Config
    return {
        name = "Mineswepper",
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
    local player1 = Player:new("Player 1", x - 1, y -1, 1)
    local player2 = Player:new("Player 2", x + 1, y+1, 9)

    Menu.on_start = function()
        State.state = "game"
    end

    local players = {
        player1, player2
    }


    State = {
        game_over = false,
        players = { player1, player2 },
        current_index_player = 1,
        current_player = player1,
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



local function refresh_score()
    local score = State.board:get_scores()
    State.score:update_score(score)
end


local function get_next_turn()
    local i = State.current_index_player
    local players = State.players

    if i >= #players then
        return 1
    end

    return i + 1
end

local function change_turn()
    local new_index = get_next_turn()
    State.current_index_player = new_index
    State.current_player = State.players[new_index]
end


local function evaluate_finishing()
    local board = State.board

    local scores = board:get_scores()

    if scores.player_open_mine ~= nil then
        State.game_over = true
        State.winner = board:get_winner()
    end

end


local function on_move(move)
    local board = State.board
    local score = State.score
    local player = State.current_player

    if move == nil then
      error("Error getting the move")
      return
    end

    if move.move == "uncover" then
      board:open(move.x, move.y, player.id)
      change_turn()
      return
    end

    if move.move == "flag" then
      local win = board:add_flag(move.x, move.y, player.id)
      if win then
        refresh_score()
      else
        change_turn()
      end
    end

    refresh_score()
end

local function turn()
  if Timer.is_waiting() then
    return
  end

  local cells = State.board.cells
  local player = State.current_player

  player:move(function(move)
      on_move(move)
      Timer.resume()
  end)

  Timer.wait()
end

local function update_game(dt)
    local board = State.board;
    local footer = State.footer;
    local score = State.score;
    local player = State.current_player

    board:update(dt)
    footer:update(dt)
    score:update(dt)
    player:update(dt)
    evaluate_finishing()
    turn()
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
    local player = State.current_player
    State.board:draw_board()
    State.footer:draw()
    State.score:draw()
    
    for _, p in ipairs(State.players) do
        p:draw()
    end

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
