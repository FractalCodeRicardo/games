require("utils")
local Constants = require("constants")
local Entity = require("entity")

local Turtle= setmetatable({}, { __index = Entity })
Turtle.__index = Turtle


function Turtle:update(dt)
  self:move_to_direction(dt)
end

function Turtle.create_turtles()
  local size = Constants.SPRITE_SIZE
  local defaults = {
    x = Constants.WIDTH,
    y = Constants.HEIGHT - 9 * size,
    w = 1,
    h = 1,
    d = 1,
    s = 50,
    sprite = 23
  }
  local turtles = {}

  table.insert(turtles, Turtle:new(Clone(defaults, {
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.10,
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.20,
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.50,
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.60,
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.70,
  })))


  defaults.sprite = 24
  defaults.y = 1 * size

  table.insert(turtles, Turtle:new(Clone(defaults, {
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.10,
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.20,
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.50,
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.60,
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.70,
  })))


  defaults.sprite = 23
  defaults.y = 2 * size
  defaults.d = - 1

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.70,
  })))

  table.insert(turtles, Turtle:new(Clone(defaults, {
    x = defaults.x * 0.35,
  })))

  return turtles
end

return Turtle
