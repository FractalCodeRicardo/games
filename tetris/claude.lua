local board_string = require("board_string")
local http = require("http")
local utils = require("utils")
local M = {}
M.__index = M

function M.new()
  local instance = setmetatable({}, M)
  instance.on_move = nil
  instance.cache = {}
  instance.name = "claude"
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

CONTROLS (the only allowed tokens)
- left    : move the piece one column left
- right   : move the piece one column right
- rotate  : rotate the piece 90 degrees clockwise
- down    : HARD DROP. The piece falls straight down and locks immediately.

OUTPUT:
Return one or more movements, separated by a comma, with no spaces.

EXAMPLES:
left,rotate,down
left
rotate,right

Do not explain your decision.
Do not output anything else.
]]
end

function M:create_input(board)
  local request = {
    -- model = "claude-opus-5-5",
    model = "claude-haiku-5-5",
    -- model = "claude-sonnet-5-5",
    max_tokens = 5000,
    system = self:create_system_prompt(),
    messages = {
      { role = "user", content = board }
    },
  }

  return usagi.to_json(request)
end

function M:move(game, on_move)
  local pending_move = self:get_pending_move()

  if pending_move ~= nil then
    print("Move: " .. pending_move)
    on_move({ move = pending_move })
    return
  end

  local board = board_string.board_to_string(game)
  local json = self:create_input(board)

  local url = "https://api.anthropic.com/v1/messages"
  local key = os.getenv("CLAUDE_API_KEY")
  local opts = {}
  opts.apiKeyHeader = "x-api-key: " .. key
  opts.extraHeader = "anthropic-version: 2023-06-01"

  print("Claude Moving...")
  print("--BOARD--")
  print(board)
  print("---------")

  http.get(url, key, json, opts, function(res)
    local moves = self:parse_move(res)
    print("Response: " .. moves)
    self:fill_cache(moves)

    local move = self:get_pending_move()
    print("Move: " .. move)
    on_move({ move = move })
  end)
end

function M:fill_cache(move)
  local moves = utils.split(move, ",")
  self.cache = moves
end

function M:get_pending_move()
  if #self.cache <= 0 then
    return nil
  end

  local move = self.cache[1]
  table.remove(self.cache, 1)
  return move
end

function M:update()
end

function M:parse_move(json)
  local result = nil
  print(usagi.dump(json))
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
