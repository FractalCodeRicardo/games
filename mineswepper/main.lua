local SIZE = 15;
local CELL_SIZE = 50;
local MINES = 40;


function _config()
  ---@type Usagi.Config
  return { 
    name = "Game",
    game_id = "com.usagiengine.YOURGAMENAME",
    game_height = SIZE * CELL_SIZE,
    game_width = SIZE * CELL_SIZE
  }
end

function create_board()
  local board = {}

  for y = 1, SIZE do
    local row = {}
    for x = 1, SIZE do
      table.insert(row, {
        x = x,
        y = y,
        value = 0,
        open = false,
        mine = false,
      })
    end
    table.insert(board, row)
  end

  return board
end

function  set_mines(board)
  for i =1, MINES do
    local x = math.random(1, SIZE)
    local y = math.random(1, SIZE)

    board[y][x].mine = true
  end
end

function is_valid_index(x, y)
  if x < 1 or x > SIZE then
    return false
  end

  if y < 1 or y > SIZE then
    return false
  end

  return true
end

function get_neightbors(board, x, y)
  local res= {}

  local dirs = {
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {0, -1},
    {0, 1},
    {1, -1},
    {1, 0},
    {1, 1},
  }

  for i, d in pairs(dirs) do
    local cell = board[y][x]
    local tx = cell.x + d[2]
    local ty = cell.y + d[1]

    if is_valid_index(tx, ty) then
      table.insert(res, board[ty][tx])
    end

  end

  return res;
end

function get_sum(board, x, y)
  local neightbors = get_neightbors(board,x, y)

  local sum = 0
  for i, n in pairs(neightbors) do

    print(string.format("%f %f  %f %f %s", x, y, n.x, n.y, n.mine))

    if n.mine then
      sum += 1
    end
  end


  return sum
end

function set_sums(board) 
  for y = 1, SIZE do
    for x = 1, SIZE do
      local sum = get_sum(board, x, y)
      board[y][x].value = sum
    end
  end
end

function _init()

  local board = create_board()
  set_mines(board)
  set_sums(board)
  State = {
    game_over = false,
    board = board
  }
end

function open_recursive(x, y)
  local neightbors = get_neightbors(State.board, x, y)
  for i, n in pairs(neightbors) do
    if n.mine == false and n.value == 0 and n.open == false then
      n.open = true
      open_recursive(n.x, n.y)
    end
  end

end

function open(mx, my)
  local board = State.board;
  local x = math.floor(mx/CELL_SIZE) + 1;
  local y = math.floor(my/CELL_SIZE) + 1;
  -- print(string.format("%f %f %f %f", mx, my, x, y))
  local cell = board[y][x];

  if (cell.mine == false) then

    cell.open = true

    if cell.value == 0 then
      open_recursive(cell.x, cell.y)
    end

    return
  end

  open_all()
  State.game_over = true;
  
end

function draw_game_over()
  gfx.text_ex("Game Over", 
  usagi.GAME_W / 2 - 180, 
  usagi.GAME_H / 2 - 100,
  8,
  0,
  gfx.COLOR_TRUE_WHITE, 1)
end
  

function open_all()
  for y = 1, SIZE do
    for x = 1, SIZE do
        State.board[y][x].open = true
    end
  end
  
end

function _update(dt)
  if input.mouse_pressed(input.MOUSE_LEFT) then
    local mx, my = input.mouse()
    open(mx, my)
  end
end

function draw_board()
  local board = State.board

  for y = 1, SIZE do
    for x = 1, SIZE do
      local sx = (x -1 ) * CELL_SIZE
      local sy = (y -1 ) * CELL_SIZE
      local cell = board[y][x]

        gfx.rect(
          sx,
          sy,
          CELL_SIZE,
          CELL_SIZE,
          gfx.COLOR_PEACH
        )


      if cell.open == true then 

        if cell.mine == false then
          gfx.text_ex(cell.value .."",
          sx + CELL_SIZE / 2 - 6 ,
          sy + CELL_SIZE / 2 - 20,
          3,0,
          gfx.COLOR_WHITE, 1
          )
        else
          gfx.text_ex("x",
          sx + CELL_SIZE / 2 - 6,
          sy + CELL_SIZE / 2 - 20 ,
          3,0,
          gfx.COLOR_GREEN, 1
          )

      end
    end

    end
  end

end


function _draw(dt)
  gfx.clear(gfx.COLOR_DARK_PURPLE)

  if State.game_over then
    draw_game_over()
  end
    draw_board()
end
