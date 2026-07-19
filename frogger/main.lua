local Frog = require("frog")
local Car = require("car")
local Constants = require("constants")

function _config()
  ---@type Usagi.Config
  return {
    name = "Frogger",
    game_id = "com.thisisthetime.frogger",
    game_height = Constants.HEIGHT,
    game_width = Constants.WIDTH
  }
end

function _init()
  local frog = Frog.create_frog()
  local cars = Car.create_cars()

  local entities = {}
  table.insert(entities, frog)
  for i = 1, #cars do
    table.insert(entities, cars[i])
  end

  State = {
    frog = frog,
    cars = cars,
    entities = entities
  }
end

function _update(dt)
    for i = 1, #State.entities do
      State.entities[i]:update(dt)
    end
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  for i = 1, #State.entities do
    State.entities[i]:draw(dt)
  end
end
