local Constans = require("constants")

local Explotion = {}

local time_peer_frame = 0.2
local frames = {5, 6, 7, 8}

Explotion.__index = Explotion;


function Explotion:new(x, y)
  local instance = setmetatable({}, Explotion)

  instance.animate = false
  instance.x = x
  instance.y = y
  instance.time = 0
  return instance
end

function Explotion:draw()
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

function Explotion:update(dt)
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

function Explotion:start()
  self.animate = true
end

return Explotion
