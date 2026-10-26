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
You are playing Tetris. Survive as long as possible and clear as many rows as possible.

BOARD:
- The board is 8 columns wide and 16 rows tall. Each text line is one row, top row first; each character is one column, left to right.
- 'x' marks a wall, the border around the board, or a settled cell.
- '*' marks the current falling piece.
- A space marks an empty cell.
- New pieces appear near the top of the board.

PIECES:
- A piece is drawn inside a 3x3 box. Rotation turns that box 90 degrees clockwise around its center.
- There are no wall kicks, and rotation is not collision-checked: only rotate when the rotated shape has room.
- Left and right moves that would hit a wall or a settled cell are ignored.

STRATEGY:
- Keep the stack low and flat.
- Avoid holes: empty cells with filled cells above them.
- Prefer placements that complete full rows.
- Avoid deep single-column wells unless they let you clear lines.
- Keep the top rows empty so new pieces can spawn.

CONTROLS (the only allowed tokens)
- left    : move the piece one column left
- right   : move the piece one column right
- rotate  : rotate the piece 90 degrees clockwise
- down    : HARD DROP. The piece falls straight down and locks immediately.

OUTPUT:
- Return the moves for the current piece only, separated by commas, with no spaces.
- The last move must be down. Nothing may come after down.

EXAMPLES:
rotate,left,left,down
right,right,down
down

Do not explain your decision.
Do not output anything else.
]]
end

function M:create_input(board)
  local request = {
    model = "claude-opus-5-5",
    -- model = "claude-haiku-5-5",
    -- model = "claude-sonnet-5-5",
    max_tokens = 8000,
    thinking = { type = "adaptive" },
    output_config = { effort = "medium" },
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

  if json.content == nil then
    local message = json.error and json.error.message or "no content in response"
    error("Claude API error: " .. message)
  end

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
