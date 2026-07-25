require("utils")
local Constants = require("constants")
local Entity = require("entity")

local Car = setmetatable({}, { __index = Entity })
Car.__index = Car

function Car:update(dt)
  self:move_to_direction(dt)
end

function Car.create_cars()
  local size = Constants.SPRITE_SIZE
  local defaults = {
    x = Constants.WIDTH,
    y = Constants.HEIGHT - 2 * size,
    w = 1,
    h = 1,
    d = -1,
    s = 50
  }

  local cars = {}
  -- First row
  defaults.sprite = 8
  table.insert(cars, Car:new(Clone(defaults, {
  })))

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.30,
  })))

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.80,
  })))

  -- Second row
  defaults.y = Constants.HEIGHT - 3 * size
  defaults.d = 1
  defaults.sprite = 7

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.20,
  })))

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.70,
  })))


  -- Third row
  defaults.y = Constants.HEIGHT - 4 * size
  defaults.d = -1
  defaults.sprite = 8

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.30
  })))

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.50
  })))

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.70
  })))


  -- Four row
  defaults.y = Constants.HEIGHT - 5 * size
  defaults.d = 1
  defaults.sprite = 7

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.50
  })))


  -- 5 row
  defaults.y = Constants.HEIGHT - 6 * size
  defaults.d = 1
  defaults.sprite = 8

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.30
  })))

  table.insert(cars, Car:new(Clone(defaults, {
    x = defaults.x * 0.60
  })))

  return cars
end

return Car
