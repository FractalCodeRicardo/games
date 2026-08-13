local Constants = require("constants")
local Explosion = require("explosion")

local SIZE = Constants.BOARD_SIZE
local MINES = Constants.MINES
local CELL_SIZE = Constants.CELL_SIZE

local Board = {}
Board.__index = Board;

function Board:new()
  local board = setmetatable({}, Board)
  board.cells = board.create_cells()

  board:set_mines()
  board:set_sums()
  return board
end

function Board.create_cell(x, y)
  local cell = {
    x = x,
    y = y,
    value = 0,
    open = false,
    mine = false,
    flag = false,
    open_by = "",
    explosion = Explosion:new(x, y)
  }

  return cell
end

function Board.create_cells()
  local board = {}

  for y = 1, SIZE do
    local row = {}
    for x = 1, SIZE do
      local cell = Board.create_cell(x, y)
      table.insert(row, cell)
    end
    table.insert(board, row)
  end

  return board
end

local function is_valid_index(x, y)
  if x < 1 or x > SIZE then
    return false
  end

  if y < 1 or y > SIZE then
    return false
  end

  return true
end

function Board:set_mines()
  for i = 1, MINES do
    local x = math.random(1, SIZE)
    local y = math.random(1, SIZE)

    while (self.cells[y][x].mine) do
      x = math.random(1, SIZE)
      y = math.random(1, SIZE)
    end

    self.cells[y][x].mine = true
  end
end

function Board:get_neightbors(x, y)
  local res = {}

  local dirs = {
    { -1, -1 },
    { -1, 0 },
    { -1, 1 },
    { 0,  -1 },
    { 0,  1 },
    { 1,  -1 },
    { 1,  0 },
    { 1,  1 },
  }

  for i, d in pairs(dirs) do
    local cell = self.cells[y][x]
    local tx = cell.x + d[2]
    local ty = cell.y + d[1]


    if is_valid_index(tx, ty) then
      table.insert(res, self.cells[ty][tx])
    end
  end

  return res;
end

function Board:get_sum(x, y)
  local neightbors = self:get_neightbors(x, y)

  local sum = 0
  for i, n in pairs(neightbors) do
    if n.mine then
      sum += 1
    end
  end

  return sum
end

function Board:set_sums()
  for y = 1, SIZE do
    for x = 1, SIZE do
      local sum = self:get_sum(x, y)
      self.cells[y][x].value = sum
    end
  end
end

function Board:open_cell(cell, player)
  cell.open = true
  cell.flag = false
  cell.explosion:start()
  cell.open_by = player
end

function Board:open_recursive(x, y, player)
  local neightbors = self:get_neightbors(x, y)
  for i, n in pairs(neightbors) do
    if n.mine then
      goto continue
    end

    if n.open then
      goto continue
    end

    self:open_cell(n, player)
    if n.value == 0 then
      self:open_recursive(n.x, n.y, player)
    end

    ::continue::
  end
end

function Board:add_flag(x, y, player)
  local cell = self.cells[y][x];

  if cell.mine and not cell.flag then
    cell.flag = true
    cell.open_by = player
    sfx.play("flag")
    return true
  end

  sfx.play("error")
  return false
end

local function get_color(player)
  if player == "cat" then
    return gfx.COLOR_BROWN
  end

  if player == "ai" then
    return gfx.COLOR_DARK_PURPLE
  end

  return gfx.COLOR_DARK_BLUE
end

function Board:open(x, y, player)
  local cell = self.cells[y][x];

  if cell.mine then
    self:open_mine(x, y, player)
  else
    self:open_non_mine(cell, player)
  end
end

function Board:open_non_mine(cell, player)
  self:open_cell(cell, player)

  if cell.value == 0 then
    self:open_recursive(cell.x, cell.y, player)
  end
end

function Board:open_mine(x, y, player)
  self.cells[y][x].open_by = player
  self.cells[y][x].open = true
end

function Board:open_all()
  for y = 1, SIZE do
    for x = 1, SIZE do
      self.cells[y][x].open = true
    end
  end
end

function Board:update(dt)
  for y = 1, SIZE do
    for x = 1, SIZE do
      self.cells[y][x].explosion:update(dt)
    end
  end
end

function Board:draw_cell(cell)
  local sx = (cell.x - 1) * CELL_SIZE
  local sy = (cell.y - 1) * CELL_SIZE


  local color = get_color(cell.open_by)
  gfx.rect(
    sx,
    sy,
    CELL_SIZE,
    CELL_SIZE,
    gfx.COLOR_PEACH
  )

  gfx.rect_fill(
    sx,
    sy,
    CELL_SIZE - 1,
    CELL_SIZE - 1,
    color
  )

  local px = sx + CELL_SIZE / 2 - 5;
  local py = sy + CELL_SIZE / 2 - 20;


  if cell.open == true then
    if cell.mine == false then
      gfx.text_ex(cell.value .. "",
        px,
        py,
        3, 0,
        gfx.COLOR_WHITE, 1
      )
    else
      gfx.text_ex("x",
        px,
        py,
        3, 0,
        gfx.COLOR_GREEN, 1
      )
    end
    return
  end

  if cell.flag then
    gfx.spr(13,
      px - 10,
      py + 3
    )
  end

  cell.explosion:draw()
end

function Board:draw_board()
  for y = 1, SIZE do
    for x = 1, SIZE do
      self:draw_cell(self.cells[y][x])
    end
  end
end

function Board:get_score()
  local opens = 0
  local flags = 0
  for y = 1, SIZE do
    for x = 1, SIZE do
      local cell = self.cells[y][x]

      if cell.open then
        opens += 1
      end

      if cell.flag then
        flags += 1
      end
    end
  end

  return {
    totalSquares = SIZE * SIZE,
    openSquares = opens,
    totalMines = Constants.MINES,
    openMines = flags
  }
end

function Board:get_winner()
  local cat = 0
  local ai = 0
  for y = 1, SIZE do
    for x = 1, SIZE do
      local cell = self.cells[y][x]

      if cell.mine and cell.open and cell.open_by == "cat" then
        return "ai"
      end

      if cell.mine and cell.open and cell.open_by == "ai" then
        return "cat"
      end

      if cell.flag and cell.mine and cell.open_by == "cat" then
        cat += 1
      end

      if cell.flag and cell.mine and cell.open_by == "ai" then
        ai += 1
      end
    end
  end

  if cat + ai == Constants.MINES then
    if cat > ai then
      return "cat"
    else
      return "ai"
    end
  end

  return nil
end

return Board
