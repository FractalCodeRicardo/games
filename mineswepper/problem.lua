local Problem = {}
Problem.__index = Problem

local problems = usagi.read_json("problems.json")

function Problem:new()
  local instance = setmetatable({}, Problem)
  instance.selection = nil
  instance.index_option = 0
  instance:select()
  return instance
end

function Problem:draw()
  if self.selection == nil then
    return
  end

  local problem = self.selection
  local start = 0
  local start_answers = start + 70
  local x_answers = 100
  gfx.text_ex(problem.description, 0, start, 1, 0, gfx.COLOR_TRUE_WHITE, 1)
  gfx.text_ex(problem.problem, 0, start + 30, 1, 0, gfx.COLOR_TRUE_WHITE, 1)


  local linea = 0
  for i,e in pairs(self.selection.options) do
      local text= string.format("%i", e)
      gfx.text_ex(text, x_answers, start_answers + linea, 1, 0, gfx.COLOR_TRUE_WHITE, 1)
      linea += 20
  end

  gfx.circ(x_answers - 10, 
    start_answers + (self.index_option * 20),
    5, gfx.COLOR_GREEN)
end

function Problem:down()
  if self.selection == nil then
    return
  end

  local option = self.index_option + 1

  if option >= #self.selection.options then
    option = 0
  end
  self.index_option = option
end

function Problem:up()
  if self.selection == nil then
    return
  end


  local option = self.index_option - 1

  if option < 0 then
    option = #self.index_option
  end

  self.index_option = option
end

function Problem:update()

  if input.key_pressed(input.KEY_DOWN) then
    self:down()
  end

  if input.key_pressed(input.KEY_UP) then
    self:up()
  end

end

function Problem:select()
  -- local index = math.random(#problems)
  local index = 1
  self.selection = problems[index]
end

return Problem
