local piece = require("piece")
local floor = require("floor")
local wall = require("wall")
local score = require("score")
local constants = require("constants")

local M = {}
M.__index = M

function M.new(config)
  local game = {}
  setmetatable(game, M)
  game.config = config
  game.piece = piece.new(config)
  game.floor = floor.new(config)
  game.wall = wall.new(config)
  game.score = score.new(config)
  game.time = 0

  return game
end

function M:handle_keys()
  if input.key_pressed(input.KEY_H) then
    self:left()
  end

  if input.key_pressed(input.KEY_L) then
    self:right()
  end

  if input.key_pressed(input.KEY_K) then
    self:rotate()
  end

  if input.key_pressed(input.KEY_J) then
    self:down()
  end
end

function M:rotate()
  self.piece:rotate()
end

function M:left()
  if self:valid_move(-1, 0) then
    self.piece:left()
  end
end

function M:right()
  if self:valid_move(1, 0) then
    self.piece:right()
  end
end

function M:down()
  local squares = self.piece:square_positions()
  local distance_y = self.floor:bottom_distance(squares)
  self.piece:move_to_direction(0, distance_y)
end

function M:update(dt)
  self:handle_crash()
  self:handle_keys()
  self:handle_movement(dt)
end

function M:handle_crash()
  local squares = self.piece:square_positions()

  if self.floor:is_crash(squares) then
    self.floor:add_squares(squares)
    self.piece = piece.new(self.config)
  end
end

function M:handle_movement(dt)
  if self.time > constants.MOVE_TIME then
    self.floor:remove_complete_lines()
    self.piece:move()
    self.time = 0
    return
  end

  self.time += dt
end

function M:valid_move(x, y)
  local positions = self.piece:square_positions()
  for _, pos in ipairs(positions) do
    pos.x += x
    pos.y += y
    if not self:valid_pos(pos) then
      return false
    end
  end

  return true
end

function M:valid_pos(pos)
  local w = constants.BOARD_SIZE.w
  local h = constants.BOARD_SIZE.h

  if pos.x < 0 or pos.x >= w then
    return false
  end

  if pos.y < 0 or pos.y >= h then
    return false
  end

  local csquares = self.floor.squares

  for _, s in ipairs(csquares) do
    if s.x == pos.x and s.y == pos.y then
      return false
    end
  end

  return true
end

function M:draw()
  self.wall:draw()
  self.piece:draw()
  self.floor:draw()
end

return M
