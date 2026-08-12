local Constants = require("constants")
local SIZE = Constants.BOARD_SIZE;

local stop_when_time = 0.6

local Cat = {}
Cat.__index = Cat

function Cat:new(name, x, y, baseSprite)
  local cat = setmetatable({}, Cat)
  cat.x = x or math.floor(SIZE / 2)
  cat.y = x or math.floor(SIZE / 2)
  cat.sprite = baseSprite
  cat.baseSprite = baseSprite
  cat.moving_time = 0
  cat.moving = false
  cat.name = name or "unnamed"
  return cat
end

function Cat:bottomSprite()
  return self.baseSprite
end

function Cat:upSprite()
  return self.baseSprite + 1
end

function Cat:rightSprite()
  return self.baseSprite + 2
end

function Cat:leftSprite()
  return self.baseSprite + 3
end

function Cat:draw()
  local sx = (self.x - 1) * Constants.CELL_SIZE;
  local sy = (self.y - 1) * Constants.CELL_SIZE;

  print(self.sprite)
  gfx.spr(self.sprite,
     2 + sx,
    3 + sy
  )
end

function Cat:move(x, y)
  local nx = self.x + x
  local ny = self.y + y

  if nx <= SIZE and nx > 0 then
    self.x = nx
  end

  if ny <= SIZE and ny > 0 then
    self.y = ny
  end
end

local function play_jump()
  sfx.play("jump")
end

function Cat:left(dt)
  self:move(-1, 0)
  self.sprite = self:leftSprite()
  self.moving = true
  self.moving_time = 0
  play_jump()
end

function Cat:right(dt)
  self:move(1, 0)
  self.sprite = self:rightSprite()
  self.moving = true
  self.moving_time = 0
  play_jump()
end

function Cat:down(dt)
  self:move(0, 1)
  self.sprite = self:bottomSprite()
  self.moving = true
  self.moving_time = 0
  play_jump()
end

function Cat:up(dt)
  self:move(0, -1)
  self.sprite = self:upSprite()
  self.moving = true
  self.moving_time = 0
  play_jump()
end

function Cat:update(dt)
  self:handle_keys()

  if self.moving then
    self.moving_time += dt
  end

  if self.moving and self.moving_time > stop_when_time then
    self.moving = false
    self.moving_time = true
    self.sprite = self.baseSprite
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
