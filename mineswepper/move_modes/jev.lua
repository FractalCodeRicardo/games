local utils = require("utils")
local http = require("http")

local M = {}
M.__index = M

function M.new()
    local instance = setmetatable({}, M)
    return instance
end

-- Facts about the game and how the board text is encoded.
-- NOTE: adjust the first line below if your board uses different
-- characters for covered / flagged / revealed cells.
function M.create_rules()
    return {
 [[
RULES:
- You will be provided by a NxN text representing a minesweeper board.
- A number indicates how many mines are in its 8 neighboring cells.
- A flagged cell contains a mine (f mark).
- A covered cell is unknown (x mark).
- You need to flag the cell the contains a covered mine.
- In case you can not determine if a covered cell has a mine, uncover a safe cell.
- You win putting as much flags as you can.
- You lose if you uncover a cell with a mine.
]]
    }
end

function M.create_instructions()
    return [[
Choose the move that has high probability to flag a mine, if you can not determine it, just uncover a cell.
Return exactly one of the moves listed in the available choices below — do not invent
a move that isn't listed.
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


                move = string.format("flag,%d,%d", x, y)

                moves[move] = string.format(
                    "Flag in column %d, row %d.",
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

    http.get(url, key, json, {}, function(res)
        local move = M.parse_move(res)
        on_move(move)
    end)
end

function M:update()
end

return M
