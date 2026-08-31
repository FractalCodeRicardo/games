local Constants = require("constants")

local AI = {}
AI.__index = AI

function AI.new()
  local instance = setmetatable({}, AI)
  return instance
end

function AI:create_input(board)
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

  local json = usagi.to_json(request)

  return json
end

function AI:send_request(board)
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

local function split(inputstr, sep)
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local function cell_as_string(cell)
  local value = "x"

  if cell.open then
    value = cell.value .. ""
  end

  if cell.flag then
    value = "f"
  end

  return value
end

function AI:board_as_string(cells)
  local size = Constants.BOARD_SIZE
  local board = ""
  for y = 1, size do
    local line = ""
    for x = 1, size do
      local cell = cells[y][x]
      local value = cell_as_string(cell)

      line = line .. value

      if x ~= size then
        line = line .. ","
      end
    end

    board = board .. line
    if y ~= size then
      board = board .. "\n"
    end
  end

  return board
end

function AI:get_move(cells, callback)
  local board = self:board_as_string(cells)

  print("Sending request...")
  print(board)
  local res = self.send_request(board)

  local file = io.open("data/response.json", "w")

  if file == nil then
    error("Error opening file")
  end

  file:write(res)
  file:close()

  local json = usagi.read_json("response.json")
  -- local content = json.output[1].content[1]
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

  local text_split = split(content.text, ",")

  local move = {
    move = text_split[1],
    x = tonumber(text_split[2]),
    y = tonumber(text_split[3]),
  }

  print("Move:")
  print(content.text)

  callback(move)
end

function AI:update()
end

return AI
