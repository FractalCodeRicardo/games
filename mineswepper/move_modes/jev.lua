local utils = require("utils")
local http = require("http")

local M = {}
M.__index = M

function M.new()
    local instance = setmetatable({}, M)
    return instance
end

function M.create_rules()
    return {
        "A number indicates how many mines are in its 8 neighboring cells.",
        "A flagged cell is believed to contain a mine.",
        "A covered cell is unknown.",
        "Never uncover a cell known to contain a mine.",
        "Prefer flag cells where there is a mine, and then logically guaranteed safe moves.",
        "If no guaranteed safe move exists, choose the move with the highest probability of being safe.",
        "To win, you need to place as much flags as you can."
    }
end

function M.create_instructions()
    return [[
Choose the best next move in the Minesweeper board.

Prefer flag cells where there is a mine, and then logically guaranteed safe moves.
Never uncover a cell that is known to contain a mine.
If no guaranteed safe move exists, choose the covered cell with the highest probability of being safe.

Return exactly one of the available moves.
]]
end

function M:create_input(board)
    local request = {
        model = "jev-latest",

        state = {
            game = "Minesweeper",
            board = board,
            rules = M.create_rules(),
            coordinates = {
                x = "column",
                y = "row",
                origin = "(1,1) is the top-left cell"
            }
        },

        questions = {
            move = {
                type = "choice",
                instructions = M.create_instructions(),
                criteria = M.create_moves(board)
            }
        }
    }
    return usagi.to_json(request)
end

M.create_moves = function(board)
    local moves = {}

    local y = 0

    for line in board:gmatch("[^\n]+") do
        y = y + 1

        local x = 0

        for cell in line:gmatch("[^,]+") do
            x = x + 1

            if cell == "x" then
                local move = string.format("uncover,%d,%d", x, y)

                moves[move] = string.format(
                    "Uncover column %d, row %d.",
                    x,
                    y
                )
            end
        end
    end

    return moves
end


M.parse_move= function (json)
    local answer = json.answers.move

    if answer == nil then
        error("No move returned by Jev")
    end

    local text = answer.choice or answer

    print("----Move:")
    print(text)

    local text_split = utils.split(text, ",")

    local move = {
        move = text_split[1],
        x = tonumber(text_split[2]),
        y = tonumber(text_split[3]),
    }

    return move
end


function M:move(on_move, cells)

    local board = utils.board_as_string(cells)
    local json = self:create_input(board)

    local url ="https://api.typesafe.ai/v1/systemone"
    local key = os.getenv("TYPESAFE_API_KEY")

    http.get(url, key, json, function(res)
        local move = M.parse_move(res)
        on_move(move)
    end)
end

function M:update()
end

return M
