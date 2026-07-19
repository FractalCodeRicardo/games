local Constants = require("constants")
local Entity = require("entity")
---@class Frog
---@field x number
---@field y number

local Frog = setmetatable({},{__index = Entity})
Frog.__index = Frog;


function Frog:handleKeys()
  local size = Constants.SPRITE_SIZE
  if (input.key_pressed(input.KEY_J)) then
   self:move(0, size)
  end

  if (input.key_pressed(input.KEY_K)) then
   self:move(0, -size)
  end

  if (input.key_pressed(input.KEY_H)) then
   self:move(-size, 0)
  end

  if (input.key_pressed(input.KEY_L)) then
   self:move(size, 0)

  end
end

function Frog:update()
  self:handleKeys()
end


function Frog.create_frog()
  local x = Constants.WIDTH / 2
  local y = Constants.HEIGHT - Constants.SPRITE_SIZE ;

  return Frog:new({x = x, y = y, sprite = 15})
end


return Frog
