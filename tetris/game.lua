local piece = require("piece")
local floor = require("floor")
local constants = require("constants")

local M = {}
M.__index = M

function M.new()
  local game = {}
  game = setmetatable(game, M)
  game.piece = piece.new()
  game.floor = floor:new()
  game.time = 0
  return game
end

function M:handle_keys()
  if input.key_pressed(input.KEY_K) then
    self:rotate()
  end

  if input.key_pressed(input.KEY_L) then
    self:right()
  end

  if input.key_pressed(input.KEY_H) then
    self:left()
  end

  if input.key_pressed(input.KEY_J) then
    self:down()
  end
end

function M:rotate()
  self.piece:rotate()
end

function M:left()
  if not self:valid_move(-1, 0) then
    return
  end

  self.piece:left()
end

function M:right()
  if not self:valid_move(1, 0) then
    return
  end

  self.piece:right()
end

function M:down()
  local squares = self.piece:square_positions()
  local distance_y = self.floor:bottom_distance(squares)
  self.piece:move_to_direction(0, distance_y)
end

function M:handle_move(dt)
  if self.time > constants.MOVE_TIME then
    self.floor:remove_complete_lines()
    self.piece:move()
    self.time = 0
    return
  end

  self.time += dt
end

function M:handle_crash()
  local squares = self.piece:square_positions()

  if self.floor:crash(squares) then
    self.floor:add_piece(squares)
    self.piece = piece:new()
  end
end

function M:update(dt)
  self:handle_crash()
  self:handle_move(dt)
  self:handle_keys()
  self.piece:update(dt)
end

function M:draw(dt)
  self.piece:draw(dt)
  self.floor:draw(dt)
end

function M:valid_move(x, y)
  local positions = self.piece:square_positions()
  for _, p in pairs(positions) do
    p.x += x
    p.y += y

    if not self:valid_pos(p) then
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

  for _, s in pairs(self.floor.squares) do
    if pos.x == s.x and pos.y == s.y then
      return false
    end
  end

  return true
end

return M
