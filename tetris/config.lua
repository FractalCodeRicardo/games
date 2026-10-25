local M = {}
M.__index = M

function M.new(config) 
  local instance = {
    pos = config.pos or { x = 0, y = 0}
  }

  instance = setmetatable(instance, M)
  return instance
end
