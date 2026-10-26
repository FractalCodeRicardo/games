local board_string = require("board_string")
local http = require("http")
local utils = require("utils")
local M = {}
M.__index = M

function M.new()
  local instance = setmetatable({}, M)
  instance.on_move = nil
  instance.cache = {}
  instance.name = "openai"
  return instance
end

function M:create_input(board)
  local request = {
    model = "gpt-6-luna",
    reasoning = { effort = "low" },
    service_tier = "fast",
    instructions = [[
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
Return one or more movements, separated by a comma:
left
right
rotate
down

EXAMPLES:
left,rotate,down
left
rotate,right

Do not explain your decision.
Do not output anything else.

]],
    input = board
  }

  local json = usagi.to_json(request)

  return json
end

function M:move(game, on_move)
  local pending_move = self:get_pending_move();

  if pending_move ~= nil then
    print("Move: " .. pending_move)
    on_move({ move = pending_move })
    return
  end

  local board = board_string.board_to_string(game)
  local json = self:create_input(board)
  local url = "https://api.openai.com/v1/responses"
  local key = os.getenv("OPENAI_API_KEY")

  print("Open AI Moving...")
  print("--BOARD--")
  print(board)
  print("---------")

  http.get(url, key, json, {}, function(res)
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
