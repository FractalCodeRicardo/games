local piece = require("piece")
local floor = require("floor")
local wall = require("wall")
local score = require("score")
local constants = require("constants")
local keyboard_mode = require("keyboard_mode")
local game_over = require("game_over")

local M = {}
M.__index = M

function M.new(config, mode)
  local game = {}
  setmetatable(game, M)
  game.config = config
  game.piece = piece.new(config)
  game.floor = floor.new(config)
  game.wall = wall.new(config)
  game.score = score.new(config)
  game.time = 0
  game.mode = mode or keyboard_mode:new()
  game.game_over = game_over.new(config)
  game.is_moving = false
  game.ai_time = 0


  if game.mode.name == "keyboard" then
    game.mode:move(game, function(move)
      game:perform_move(move.move)
    end)
  end
  return game
end

function M:perform_move(move)
  if move == "left" then
    self:left()
  end

  if move == "right" then
    self:right()
  end

  if move == "rotate" then
    self:rotate()
  end

  if move == "down" then
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
  if self.floor:is_game_over() then
    return
  end
  self:handle_crash()
  self:handle_movement(dt)
  self.mode:update();

  self:ai_move(dt)
end

function M:ai_move(dt)
  if self.mode.name == "keyboard" then
    return
  end

  if self.is_moving then
    return
  end

  if self.ai_time < constants.MOVE_AI_TIME then
    self.ai_time += dt
    return
  end

  self.ai_time = 0
  self.is_moving = true
  self.mode:move(self, function(move)
    self:perform_move(move.move)
    self.is_moving = false
  end)
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
    local count = self.floor:remove_complete_lines()
    self.score:update_score(count)
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
  if self.floor:is_game_over() then
    self.game_over:draw()
    return
  end

  self.wall:draw()
  self.piece:draw()
  self.floor:draw()
  self.score:draw()
end

return M
