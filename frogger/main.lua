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

  local obstacles = {}
  AppendAll(obstacles, cars)

  local floats = {}
  AppendAll(floats, trunks)
  AppendAll(floats, turtles)

  State = {
    map = Map,
    frog = frog,
    cars = cars,
    obstacles = obstacles,
    floats = floats
  }
end

local function update_entities(entities, dt)
  for i = 1, #entities do
    entities[i]:update(dt)
  end
end

local function draw_entities(entities, dt)
  for i = 1, #entities do
    entities[i]:draw(dt)
  end
end

function _update(dt)
  local obstacles = State.obstacles
  local floats = State.floats
  local frog = State.frog

  update_entities(obstacles, dt)
  update_entities(floats, dt)

  frog:update(dt)

  if CollidesWith(frog, obstacles) then
    frog:die()
  end

  local float = GetCollidedEntity(frog, floats)
  if float ~= nil then
    frog.d = float.d
    frog.s = float.s
    frog:move_to_direction(dt)
    frog.d = 0
    frog.s = 0
  end

end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)

  local obstacles = State.obstacles
  local floats = State.floats
  local frog = State.frog
  State.map:draw()
  draw_entities(obstacles, dt)
  draw_entities(floats, dt)
  State.frog:draw()
end
