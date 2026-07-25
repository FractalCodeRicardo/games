---@class Parameters
---@field x integer
---@field y integer
---@field w integer?
---@field h integer?
---@field d integer?
---@field s integer?
---@field color integer?
---@field sprite integer?


local Constants = require("constants")

local Entity = {}
Entity.__index = Entity

---
---@param params Parameters
function Entity:new(params)
  local entity = {
    x = params.x,
    y = params.y,
    w = params.w or 1,
    h = params.h or 1,
    d = params.d or 1,
    s = params.s or 1,
    color = params.color or gfx.COLOR_DARK_PURPLE,
    sprite = params.sprite or -1
  }

 setmetatable(entity, self)
 return entity
end


function Entity:move_to_direction(dt)
  if (self.d > 0 and self.x > Constants.WIDTH) then
    self.x = Constants.SPRITE_SIZE * self.w * -1;
    return
  end

  if (self.d < 0 and self.x + self.w * Constants.SPRITE_SIZE < 0) then
    self.x = Constants.WIDTH
    return
  end

  local x = dt * self.d * self.s;
  self:move(x, 0)
end

function Entity:draw()
  if (self.sprite < 0) then
    self:draw_rect()
    return
  end

  self:draw_sprite()
end

function Entity:draw_sprite()
  for i=1, self.w do
    local j = i -1
    local x = self.x + (j* Constants.SPRITE_SIZE)
    gfx.spr(self.sprite + j, x, self.y)
  end
end

function Entity:draw_rect()
  local size = Constants.SPRITE_SIZE;
  gfx.rect_fill(
    self.x,
    self.y,
    size * self.w,
    size * self.h,
    self.color)
end

function Entity:move(x, y)
 self.x += x
 self.y += y
end

return Entity
