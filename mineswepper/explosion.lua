local Constans = require("constants")

local Explosion = {}

local time_peer_frame = 0.2
local frames = {5, 6, 7, 8}

Explosion.__index = Explosion;


function Explosion:new(x, y)
  local instance = setmetatable({}, Explosion)

  instance.animate = false
  instance.x = x
  instance.y = y
  instance.time = 0
  return instance
end

function Explosion:draw()
  if not self.animate then
    return
  end

  local frameIndex = math.floor(self.time / time_peer_frame)

  if frameIndex > #frames then
    return
  end

  local sx = (self.x -1) * Constans.CELL_SIZE;
  local sy = (self.y -1) * Constans.CELL_SIZE;

  local frame = frames[frameIndex+1]
  gfx.spr(frame, sx, sy)

end

function Explosion:update(dt)
  if not self.animate then
    return
  end

  if self.time + 0.1 > #frames * time_peer_frame then
    self.animate = false
    self.time = 0
    return
  end

  self.time += dt
end

function Explosion:start()
  self.animate = true
  sfx.play("explosion")
end

return Explosion
