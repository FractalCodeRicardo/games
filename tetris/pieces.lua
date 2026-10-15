local M = {}

local squares = {
  {
    0, 1, 0,
    0, 1, 0,
    0, 1, 0,
  },
  {
    1, 1, 0,
    1, 1, 0,
    0, 0, 0
  },
  {
    0, 1, 0,
    1, 1, 1,
    0, 0, 0,
  },

  {
    0, 1, 1,
    1, 1, 0,
    0, 0, 0,
  },
  {
    1, 1, 0,
    0, 1, 1,
    0, 0, 0,
  },
  {
    1, 0, 0,
    1, 1, 1,
    0, 0, 0,
  },
  {
    0, 0, 1,
    1, 1, 1,
    0, 0, 0,
  },
}

function M.random()
  return squares[math.random(#squares)]
end

return M
