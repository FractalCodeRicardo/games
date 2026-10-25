local board_string = require("board_string")
local http = require("http")
local M = {}
M.__index = M

function M.new()
    local instance = setmetatable({}, M)
    instance.on_move = nil
    return instance
end

function M:create_system_prompt()
    return [[
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
]]
end

function M:create_input(board)
    local request = {
        model = "claude-opus-5-5",
        max_tokens = 1024,
        system = M:create_system_prompt(),
        messages = {
            { role = "user", content = board }
        },
    }

    return usagi.to_json(request)
end

function M:move(on_move, game)
    local board = board_string.board_to_string(game)
    local json = self:create_input(board)

    local url = "https://api.anthropic.com/v1/messages"
    local key = os.getenv("CLAUDE_API_KEY")
    local opts = {}
    opts.apiKeyHeader = "x-api-key: " .. key
    opts.extraHeader = "anthropic-version: 2023-06-01"

    http.get(url, key, json, opts, function(res)
        local move = M:parse_move(res)
        on_move({ move = move })
    end)
end

function M:update()
end

function M:parse_move(json)
    local result = nil

    for i = 1, #(json.content) do
        local output = json.content[i]
        if output.type == "text" then
            result = output.text
        end
    end

    if result == nil then
        error("Error parsing response")
    end

    local move = result:gsub("%s+", "")
    return move
end

return M
