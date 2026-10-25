local board_string = require("board_string")
local http = require("http")
local M = {}
M.__index = M

function M.new()
    local instance = setmetatable({}, M)
    instance.on_move = nil
    return instance
end

function M:create_input(board)
    local request = {
        model = "gpt-6-luna",
        instructions = [[
You are playing Tetris.

RULES:
- You will be provided by a text representation of the board.
- 'x' marks a wall or a settled floor cell.
- '*' marks the current piece.
- A space marks an empty cell.

OUTPUT:
Return ONLY one of:
left
right
rotate
down

Do not explain your decision.
Do not output anything else.
]],
        input = board
    }

    local json = usagi.to_json(request)

    return json
end

function M:move(game, on_move)
    local board = board_string.board_to_string(game)
    local json = self:create_input(board)
    local url = "https://api.openai.com/v1/responses"
    local key = os.getenv("OPENAI_API_KEY")

    http.get(url, key, json, {}, function(res)
        self.ai_pending = false
        local move = M:parse_move(res)
        on_move({ move = move })
    end)
end

function M:update()
end

function M:parse_move(json)
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

    local text = content.text or ""
    local move = text:gsub("%s+", "")
    return move
end

return M
