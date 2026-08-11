local Constants = require("constants")
local AI = {}

function AI.create_input(board)
local request = {
    model = "gpt-5.4-mini",
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

function AI.send_request(board)
  local json = AI.create_input(board)
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
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function AI.board_as_string(cells)
  local size = Constants.BOARD_SIZE
  local board = ""
  for y = 1, size do
    local line = ""
    for x = 1, size do
      local cell = cells[y][x]
      local value = "x"

      if cell.open then
        value = cell.value .. ""
      end

      if cell.flag then
        value = "f"
      end
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

function AI.get_move(cells)
  local board = AI.board_as_string(cells)

  print("Sending request...")
  print(board)
  local res = AI.send_request(board)
  print("ok...")

  local file = io.open("data/response.json", "w")

  if file == nil then
    error("Error opening file")
  end

  file:write(res)
  file:close()

  local json = usagi.read_json("response.json")


  local content = json.output[1].content[1]
  local text_split = split(content.text, ",")

  return {
    move = text_split[1],
    x = tonumber(text_split[2]),
    y = tonumber(text_split[3]),
  }
end

return AI
