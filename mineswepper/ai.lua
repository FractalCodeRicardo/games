local Constants = require("constants")
local AI = {}

function AI.create_input(board)
local request = {
    model = "gpt-5-mini",
    instructions = [[
You are a minesweeper player. You will receive the board as a text with this format:

- N rows divided by linebreaks
- Each row contains N columns separated by a comma
- Each element can have these values:
  0 - cover cell
  f - flag
  Number - uncover cell with Number mines around
- You must respond with uncover,x,y where x is the column number and y is the row number to uncover that cell.
- You must respond with flag,x,y to put a flag in that cell.
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
    print("Error on io.popen")
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
      local value = "0"

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
  local res = AI.send_request(board)

  local file = io.open("data/response.json", "w")

  if file == nil then
    print("Error opening file")
    return nil
  end

  file:write(res)
  file:close()

  local json = usagi.read_json("response.json")
  local text = json.output[2].content[1].text
  local text_split = split(text)

  return {
    move = text_split[1],
    x = text_split[2],
    y = text_split[3],
  }
end

return AI
