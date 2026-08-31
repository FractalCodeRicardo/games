local Keyboard = {}
Keyboard.__index = Keyboard

function Keyboard.new(player)
  local instance = setmetatable({}, Keyboard)
  instance.player = player
  instance.block_events = true
end

function Keyboard:update()
  if not self.block_events then
    self:handle_keys()
  end
end

function Keyboard:handle_keys()
  if input.key_released(input.KEY_RIGHT) then
    self.player:right()
  end

  if input.key_pressed(input.KEY_LEFT) then
    self.player:left()
  end

  if input.key_pressed(input.KEY_UP) then
    self.player:up()
  end

  if input.key_pressed(input.KEY_DOWN) then
    self.player:down()
  end

  -- uncover
  if input.key_pressed(input.KEY_Q) then
    self.block_events = true
    self.on_move({
      move = "uncover",
      x = self.player.x,
      y = self.player.y
    })
  end

  --flag
  if input.key_pressed(input.KEY_W) then
    self.block_events = true
    self.on_move({
      move = "flag",
      x = self.player.x,
      y = self.player.y
    })
  end
end

function Keyboard:move(on_move)
  self.block_events = false
  self.on_move = on_move
end


return Keyboard
