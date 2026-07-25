require("utils")
local Constants = require("constants")
local Entity = require("entity")

local Trunk = setmetatable({}, { __index = Entity })
Trunk.__index = Trunk

function Trunk:update(dt)
  self:move_to_direction(dt)
end

function Trunk.create_trunks()
  local size = Constants.SPRITE_SIZE
  local row = Constants.SPRITE_HEIGHT -6 -2 ;
  row = row * size;
  local defaults = {
    x = Constants.WIDTH,
    y = row ,
    w = 2,
    h = 1,
    d = -1,
    s = 50,
    sprite = 10
  }

  local trunks = {}

  table.insert(trunks, Trunk:new(Clone(defaults, {
    x = Constants.WIDTH
  })))

  table.insert(trunks, Trunk:new(Clone(defaults, {
    x = Constants.WIDTH * 0.8
  })))

  table.insert(trunks, Trunk:new(Clone(defaults, {
    x = Constants.WIDTH * 0.4
  })))

  table.insert(trunks, Trunk:new(Clone(defaults, {
    x = Constants.WIDTH * 0.2
  })))


  defaults.y -= Constants.SPRITE_SIZE * 2
  defaults.d = 1
  defaults.w = 3

  table.insert(trunks, Trunk:new(Clone(defaults, {
    x = Constants.WIDTH * 0.2
  })))

  table.insert(trunks, Trunk:new(Clone(defaults, {
    x = Constants.WIDTH * 0.6
  })))
  return trunks
end

return Trunk
