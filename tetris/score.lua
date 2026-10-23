local M = {}
M.__index = M


function M.new()
  local score = {}
  setmetatable(score, M)

  score.value = 0

  return score
end

function M:get_value()
  return self.value
end

function M:set_value(value)
  self.value = value
end

function M:add_value(value)
  self.value = self.value + value
end

return M
