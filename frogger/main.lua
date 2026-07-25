local Frog = require("frog")
local Car = require("car")
local Constants = require("constants")
local Map = require("map")
local Trunk = require("trunk")
local Turtles = require("turtles")

require("utils")

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
  local trunks = Trunk.create_trunks();
  local turtles = Turtles.create_turtles()

  local entities = {}
  table.insert(entities, frog)
  AppendAll(entities, cars)
  AppendAll(entities, trunks)
  AppendAll(entities, turtles)

  State = {
    map = Map,
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

  State.map:draw()
  for i = 1, #State.entities do
    State.entities[i]:draw(dt)
  end

end
