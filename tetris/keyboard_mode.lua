local M = {}
M.__index = M

function M.new()
  local instance = setmetatable({}, M)
  instance.block_events = true
  instance.name = "keyboard"

  return instance
end

function M:update()
  if not self.block_events then
    self:handle_keys()
  end
end

function M:handle_keys()
  local mov = nil
  if input.key_released(input.KEY_RIGHT) then
    mov = "right"
  end

  if input.key_pressed(input.KEY_LEFT) then
    mov = "left"
  end

  if input.key_pressed(input.KEY_UP) then
    mov = "rotate"
  end

  if input.key_pressed(input.KEY_DOWN) then
    mov = "down"
  end

  if mov ~= nil then
    -- print(mov)
    self.on_move({
      move = mov 
    })
  end
end

function M:move(game, on_move)
  self.block_events = false
  self.on_move = on_move
end

return M
