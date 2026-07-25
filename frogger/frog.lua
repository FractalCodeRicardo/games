local Constants = require("constants")
local Entity = require("entity")

local Frog = setmetatable({},{__index = Entity})
Frog.__index = Frog;


function Frog:handleKeys()
  local size = Constants.SPRITE_SIZE
  if (input.key_pressed(input.KEY_J)) then
   self:move(0, size)
   self.sprite = 16
  end

  if (input.key_pressed(input.KEY_K)) then
   self:move(0, -size)
   self.sprite = 15
  end

  if (input.key_pressed(input.KEY_H)) then
   self:move(-size, 0)
   self.sprite = 17
  end

  if (input.key_pressed(input.KEY_L)) then
   self:move(size, 0)
   self.sprite = 18
  end
end

function Frog:update()
  self:handleKeys()
end


function Frog.create_frog()
  local x = Constants.WIDTH / 2
  local y = Constants.HEIGHT - Constants.SPRITE_SIZE ;

  local frog = Frog:new({x = x, y = y, sprite = 15})
  return frog
end


return Frog
