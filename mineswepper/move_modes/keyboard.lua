local Keyboard = {}

function Keyboard.update()
  Keyboard.handle_keys()
end

function Keyboard.get_move(callback)
  
end


function Keyboard.handle_keys()
  if input.key_released(input.KEY_RIGHT) then
    self:right()
  end

  if input.key_pressed(input.KEY_LEFT) then
    self:left()
  end

  if input.key_pressed(input.KEY_UP) then
    self:up()
  end

  if input.key_pressed(input.KEY_DOWN) then
    self:down()
  end
end


return Keyboard
