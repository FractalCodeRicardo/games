local Constants = require("constants")
local SIZE = Constants.BOARD_SIZE;

local stop_when_time = 0.6

local Player = {}
Player.__index = Player

function Player:new(name, x, y, baseSprite)
  local player = setmetatable({}, Player)
  player.x = x or math.floor(SIZE / 2)
  player.y = x or math.floor(SIZE / 2)
  player.sprite = baseSprite
  player.baseSprite = baseSprite
  player.moving_time = 0
  player.moving = false
  player.name = name or "unnamed"
  return player
end

function Player:bottomSprite()
  return self.baseSprite
end

function Player:upSprite()
  return self.baseSprite + 1
end

function Player:rightSprite()
  return self.baseSprite + 2
end

function Player:leftSprite()
  return self.baseSprite + 3
end

function Player:draw()
  local sx = (self.x - 1) * Constants.CELL_SIZE;
  local sy = (self.y - 1) * Constants.CELL_SIZE;

  gfx.spr(self.sprite,
    2 + sx,
    3 + sy
  )
end

function Player:move(x, y)
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

function Player:left(dt)
  self:move(-1, 0)
  self.sprite = self:leftSprite()
  self.moving = true
  self.moving_time = 0
  play_jump()
end

function Player:right(dt)
  self:move(1, 0)
  self.sprite = self:rightSprite()
  self.moving = true
  self.moving_time = 0
  play_jump()
end

function Player:down(dt)
  self:move(0, 1)
  self.sprite = self:bottomSprite()
  self.moving = true
  self.moving_time = 0
  play_jump()
end

function Player:up(dt)
  self:move(0, -1)
  self.sprite = self:upSprite()
  self.moving = true
  self.moving_time = 0
  play_jump()
end

function Player:update(dt)
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


function Player:handle_keys()
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

function Player:move_to(x, y)
  local dx = math.abs(self.x - x)
  local dy = math.abs(self.y - y)
  while dx >= 2 or dy >= 2 do
    if self.x < x then
      self.x += 1
    end

    if self.x > x then
      self.x -= 1
    end

    if self.y < y then
      self.y += 1
    end

    if self.y > y then
      self.y -= 1
    end


    dx = math.abs(self.x - x)
    dy = math.abs(self.y - y)
  end
end

return Player
