local utils = require("utils")
local http = require("http")
local M = {}
M.__index = M

function M.new()
    local instance = setmetatable({}, M)
    return instance
end

function M:create_input(board)
    print("Creating request")
    local request = {
        model = "gpt-5.6-sol",
        instructions = [[
You are playing Minesweeper.

RULES:
- A number indicates how many mines are in its 8 neighboring cells.
- A flagged cell is believed to contain a mine.
- A covered cell is unknown.
- You can uncover a covered cell or flag a covered cell.
- Never uncover a cell that you know contains a mine.
- Prefer moves that are logically guaranteed to be safe.
- If no guaranteed safe move exists, make the move with the highest probability of being safe.
- To win you have to put a flag in each mine

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

    print(request)
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
    print(json)
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

    print("Move:")
    print(content.text)

    return move
end

function M:move(on_move, cells)
    local board = utils.board_as_string(cells)
    local json = self:create_input(board)

    local url ="https://api.openai.com/v1/responses"
    local key = os.getenv("OPENAI_API_KEY")
    http.get(url, key, json, function(res)
        local move = M.parse_move(res)
        on_move(move)
    end)
end

function M:update()
end

return M
