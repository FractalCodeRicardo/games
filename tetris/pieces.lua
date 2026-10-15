local M  = {}

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

M.random = function ()
  return squares[math.random(#squares)]
end

return M
