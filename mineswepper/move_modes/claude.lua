local utils = require("utils")
local http = require("http")
local M = {}
M.__index = M

function M.new()
    local instance = setmetatable({}, M)
    return instance
end

-- Board legend matches your original prompt: 'x' = covered/unknown,
-- 'f' = flagged (believed mine), a digit = revealed mine-count.
function M.create_system_prompt()
    return [[
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
]]
end

function M:create_input(board)
    local request = {
        model = "claude-opus-5-5",
        max_tokens = 1024,
        system = M.create_system_prompt(),
        messages = {
            { role = "user", content = board }
        },
    }

    local json = usagi.to_json(request)

    return json
end


-- Claude's response puts the structured move directly on a tool_use
-- content block's `input` table — no string-splitting needed.
function M.parse_move(json)
    local result = nil


    for i = 1, #(json.content) do
        local output = json.content[i]
        if output.type == "text" then
            result = output.text
        end
    end

    local split = utils.split(result, ",") 
    local move = {
        move = split[1],
        x = tonumber(split[2]),
        y = tonumber(split[3]),
    }


    return move
end

function M:move(on_move, cells)
    local board = utils.board_as_string(cells)
    local json = self:create_input(board)

    local url = "https://api.anthropic.com/v1/messages"
    local key = os.getenv("CLAUDE_API_KEY")
    local opts = {}

    opts.apiKeyHeader = "x-api-key: " .. key
    opts.extraHeader = "anthropic-version: 2023-06-01" 

    http.get(url, key, json, opts, function(res)
        local move = M.parse_move(res)
        on_move(move)
    end)
end

function M:update()
end

return M
