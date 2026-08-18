local Constants = require("constants")

local states = Constants.states

local Timer = {}

function Timer.is_waiting()
  return State.state == states.waiting
end

function Timer.wait()
  State.state = states.waiting
end

function Timer.resume()
  State.state = states.playing
  State.delay_time = nil
end

function Timer.delay(miliseconds)
  State.state = states.waiting
  State.delay_time = miliseconds
end

function Timer.handle_waiting(dt)
  if State.delay_time == nil then
    return
  end

  local new_time = State.delay_time - dt * 1000;
  if new_time < 0 then
    Timer.resume()
  else
    State.delay_time = new_time
  end
end

return Timer
