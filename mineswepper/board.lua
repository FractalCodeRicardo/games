local Constants = require("constants")
local Explosion = require("explosion")

local SIZE = Constants.SIZE
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

function Board:open_cell(cell)
    cell.open = true
    cell.explosion:start()
end

function Board:open_recursive(x, y)
  local neightbors = self:get_neightbors(x, y)
  for i, n in pairs(neightbors) do
    if n.mine then
      goto continue
    end

    if n.open then
      goto continue
    end

    self:open_cell(n)
    if n.value == 0 then
      self:open_recursive(n.x, n.y)
    end

    ::continue::
  end
end

function Board:open(x, y)

  local cell = self.cells[y][x];

  if cell.mine then
    self:open_mine()
  else
    self:open_non_mine(cell)
  end
end

function Board:open_non_mine(cell)
  self:open_cell(cell)

  if cell.value == 0 then
    self:open_recursive(cell.x, cell.y)
  end
end

function Board:open_mine()
  self:open_all()
  State.game_over = true;
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

function Board:draw_board()
  for y = 1, SIZE do
    for x = 1, SIZE do
      local sx = (x - 1) * CELL_SIZE
      local sy = (y - 1) * CELL_SIZE
      local cell = self.cells[y][x]

      cell.explosion:draw()

      gfx.rect(
        sx,
        sy,
        CELL_SIZE,
        CELL_SIZE,
        gfx.COLOR_PEACH
      )


      if cell.open == true then
        if cell.mine == false then
          gfx.text_ex(cell.value .. "",
            sx + CELL_SIZE / 2 - 6,
            sy + CELL_SIZE / 2 - 20,
            3, 0,
            gfx.COLOR_WHITE, 1
          )
        else
          gfx.text_ex("x",
            sx + CELL_SIZE / 2 - 6,
            sy + CELL_SIZE / 2 - 20,
            3, 0,
            gfx.COLOR_GREEN, 1
          )
        end
      end
    end
  end
end

return Board
