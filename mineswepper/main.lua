local Constants = require("constants")
local Board = require("board")
local Player = require("player")
local Footer = require("footer")
local Score = require("score")
local Menu = require("menu")
local Timer = require("timer")
local AI = require("move_modes.openai")
local JEV = require("move_modes.jev")
local CLAUDE = require("move_modes.claude")

local SIZE = Constants.BOARD_SIZE;
local CELL_SIZE = Constants.CELL_SIZE;
local MINES = Constants.MINES;
local states = Constants.states;
local HTTP = require("http")


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

local function keyboard_players()
    
    local y = math.floor(SIZE / 2)
    local x = math.floor(SIZE / 2)
    local p1 = Player:new("Player 1", x - 1, y - 1, 1)
    local p2 = Player:new("Player 2", x + 1, y + 1, 9)
    return { p1, p2 }
end

local function jev_players()
    local y = math.floor(SIZE / 2)
    local x = math.floor(SIZE / 2)
    local ai_mode = JEV:new()
    local p1 = Player:new("Ricardo", x - 1, y - 1, 1)
    local p2 = Player:new("Jev AI", x + 1, y + 1, 9, {
        mode = ai_mode
    })
    return { p1, p2 }
end

local function openAI_players()
    local y = math.floor(SIZE / 2)
    local x = math.floor(SIZE / 2)
    local ai_mode = AI:new()
    local p1 = Player:new("Ricardo", x - 1, y - 1, 1)
    local p2 = Player:new("Open AI", x + 1, y + 1, 9, {
        mode = ai_mode
    })
    return { p1, p2 }
end


local function openAI_vs_jev_players()
    local y = math.floor(SIZE / 2)
    local x = math.floor(SIZE / 2)
    local ai_mode = AI:new()
    local jev = JEV:new()
    local p1 = Player:new("Jev", x - 1, y - 1, 1, {
        mode = jev
    })
    local p2 = Player:new("Open AI", x + 1, y + 1, 9, {
        mode = ai_mode
    })
    return { p1, p2 }
end


local function gpt_vs_jev()
    local y = math.floor(SIZE / 2)
    local x = math.floor(SIZE / 2)
    local claude = CLAUDE:new()
    local jev = JEV:new()
    local p1 = Player:new("Claude", x - 1, y - 1, 1, {
        mode = claude
    })
    local p2 = Player:new("Jev", x + 1, y + 1, 9, {
        mode = jev
    })
    return { p1, p2 }
end


local function keyboard_vs_claude()
    local y = math.floor(SIZE / 2)
    local x = math.floor(SIZE / 2)
    local claude = CLAUDE:new()
    local p1 = Player:new("Ricardo", x - 1, y - 1, 1)
    local p2 = Player:new("Claude", x + 1, y + 1, 9, {mode = claude})

    return { p1, p2 }
end

function _init()
    local board = Board:new()

    -- local players = keyboard_players()
    -- local players = openAI_players()
    -- local players = openAI_vs_jev_players()
    -- local players = keyboard_vs_claude()
    local players = gpt_vs_jev()

    Menu.on_start = function()
        State.state = "game"
    end


    State = {
        game_over = false,
        players = players,
        current_index_player = 1,
        current_player = players[1],
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

        if State.winner == nil then
            for _, p in ipairs(State.players) do
                if p.id ~= scores.player_open_mine then
                    State.winner = p.id
                    break
                end
            end
        end
        return
    end

    State.winner = board:get_winner()

    if State.winner ~= nil then
        State.game_over = true
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

    Timer.wait()

    print("---- TURN " .. player.name .. " ----")
    player:move(
        function(move)

            print("MOVE:")
            print(string.format("%s (%i, %i)", move.move, move.x, move.y))
            on_move(move)
            player:move_to(move.x, move.y)
            Timer.delay(100)
        end,
        cells
    )

end

local function update_game(dt)
    local board = State.board;
    local footer = State.footer;
    local score = State.score;
    local player = State.current_player

    if State.game_over then
        footer:update(dt)
        return
    end

    footer:update(dt)
    board:update(dt)
    score:update(dt)
    player:update(dt)
    Timer.handle_waiting(dt)
    evaluate_finishing()
    turn()
end

local function update_menu()
    State.menu.update()
end

function _update(dt)
    HTTP.update()
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
