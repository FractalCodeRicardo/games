local Constants = require("constants")
local Entity = require("entity")
local Sprites =  require("sprites")

local Frog = setmetatable({},{__index = Entity})
Frog.__index = Frog;


function Frog:handleKeys()
  local size = Constants.SPRITE_SIZE
  if (input.key_pressed(input.KEY_J)) then
   self:move(0, size)
   self.sprite = Sprites.Frog1
  end

  if (input.key_pressed(input.KEY_K)) then
   self:move(0, -size)
   self.sprite = Sprites.Frog1
  end

  if (input.key_pressed(input.KEY_H)) then
   self:move(-size, 0)
   self.sprite = Sprites.Frog1
  end

  if (input.key_pressed(input.KEY_L)) then
   self:move(size, 0)
   self.sprite = Sprites.Frog1
  end
end

function Frog:update()
  if (self.is_death) then
    return
  end

  self:handleKeys()
end


function Frog.create_frog()
  local x = Constants.WIDTH / 2
  local y = Constants.HEIGHT - Constants.SPRITE_SIZE ;

  local frog = Frog:new({x = x, y = y, sprite = 15})
  frog.is_death = false;
  frog.sprite = Sprites.Frog1
  return frog
end

function Frog:die()
  self.is_death = true
  self.sprite = 21
end

return Frog
