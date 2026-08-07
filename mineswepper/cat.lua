local Constants = require("constants")
local SIZE = Constants.SIZE;

local bottomSprite = 1
local upSprite = 2
local rightSprite = 3
local leftSprite = 4

local stop_when_time = 1

local Cat = {}
Cat.__index = Cat

function Cat:new()
  local cat = setmetatable({}, Cat)
  cat.x = math.floor(SIZE / 2)
  cat.y = math.floor(SIZE / 2)
  cat.sprite = bottomSprite
  cat.moving_time = 0
  cat.moving = false
  return cat
end

function Cat:draw()
  local sx = (self.x - 1) * Constants.CELL_SIZE;
  local sy = (self.y - 1) * Constants.CELL_SIZE;
  local offset = 6

  gfx.spr(self.sprite,
    offset + sx,
    offset + sy
  )
end

function Cat:move(x,y)
  local nx = self.x + x
  local ny = self.y + y

  print(string.format("%f %f %f %f", self.x, self.y, nx, ny))
  if nx < SIZE and nx >0   then
    self.x = nx
  end

  if ny < SIZE and ny > 0 then
    self.y = ny
  end
end

function Cat:left(dt)
 self:move(-1, 0)
 self.sprite = leftSprite
 self.moving = true
 self.moving_time = 0
end

function Cat:right(dt)
 self:move(1, 0)
 self.sprite = rightSprite
 self.moving = true
 self.moving_time = 0
end

function Cat:down(dt)
 self:move(0, 1)
 self.sprite = bottomSprite
 self.moving = true
 self.moving_time = 0
end

function Cat:up(dt)
 self:move(0, -1)
 self.sprite = upSprite
 self.moving = true
 self.moving_time = 0
end

function Cat:update(dt)
  self:handle_keys()

  if self.moving then
    self.moving_time += dt
  end

  if self.moving and self.moving_time > stop_when_time then
    self.moving = false
    self.moving_time = true
    self.sprite = bottomSprite
  end
end

function Cat:handle_keys()
  if input.key_released(input.KEY_RIGHT) then
    self:right()
  end

  if input.key_pressed(input.KEY_LEFT) then
    self:left()
  end

  if input.key_pressed(input.KEY_UP) then
    self:up()
  end

  if input.key_pressed(input.KEY_DOWN) then
    self:down()
  end
end

return Cat
