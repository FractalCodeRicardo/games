local utils = require("utils")
local http = require("http")
local M = {}
M.__index = M

function M.new()
    local instance = setmetatable({}, M)
    return instance
end

function M:create_input(board)
    local request = {
        model = "gpt-5.6-sol",
        instructions = [[
You are playing Minesweeper.

RULES:
- You will be provided by a NxN text representing a minesweeper board.
- A number indicates how many mines are in its 8 neighboring cells.
- A flagged cell contains a mine (f mark).
- A covered cell is unknown (x mark).
- You need to flag the cell the contains a covered mine.
- In case you can not determine if a covered cell has a mine, uncover a safe cell.
- You win putting as much flags as you can.
- You lose if you uncover a cell with a mine.

COORDINATES:
- x = column
- y = row
- coordinates start at 1
- (1,1) is the top-left cell

OUTPUT:
Return ONLY:
uncover,x,y

or:
flag,x,y

Do not explain your decision.
Do not output anything else.
]],
        input = board
    }

    local json = usagi.to_json(request)

    return json
end

function M:send_request(board)
    local json = self:create_input(board)
    local command = string.format(
        'curl -s https://api.openai.com/v1/responses ' ..
        '-H "Content-Type: application/json" ' ..
        '-H "Authorization: Bearer %s" ' ..
        '-d %q',
        os.getenv("OPENAI_API_KEY"),
        json
    )

    local handle = io.popen(command)

    if handle == nil then
        error("Error on io.popen")
        return
    end

    local response = handle:read("*a")
    handle:close()

    return response
end

function M.parse_move(json)
    local content = nil
    for i = 1, #(json.output) do
        local output = json.output[i]
        if output.type == "message" then
            content = output.content[1]
        end
    end

    if content == nil then
        error("Error parsing response")
    end

    local text_split = utils.split(content.text, ",")

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

    local url ="https://api.openai.com/v1/responses"
    local key = os.getenv("OPENAI_API_KEY")
    http.get(url, key, json, {}, function(res)
        local move = M.parse_move(res)
        on_move(move)
    end)
end

function M:update()
end

return M
