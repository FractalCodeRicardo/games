local Constants = require("constants")
local Footer = {}
Footer.__index = Footer

local start = Constants.BOARD_SIZE * Constants.CELL_SIZE + 5; 
local start_answers = start + 30
local x_answers = 150

local problems = usagi.read_json("problems.json")

function Footer:new()
  local instance = setmetatable({}, Footer)
  instance.selection = nil
  instance.index_option = 0
  instance:select()
  return instance
end

function Footer:draw()
  if self.selection == nil then
    return
  end

  self:draw_border()
  self:draw_problem()
  self:draw_answers()

end

function Footer:draw_border()
  local w =usagi.GAME_W - 10
  local h = 30 + #self.selection.options * 21
  gfx.rect_fill(5, start - 5, w, h, gfx.COLOR_BLACK)
  gfx.rect_ex(5, start - 5, w, h, 1, gfx.COLOR_PEACH)
end

function Footer:draw_problem()
  local problem = self.selection
  gfx.text_ex(problem.description, 10, start, 1, 0, gfx.COLOR_TRUE_WHITE, 1)
  gfx.text_ex(problem.problem, 10, start + 30, 1, 0, gfx.COLOR_TRUE_WHITE, 1)
end

function Footer:draw_answers()

  local line = 0
  for i, e in pairs(self.selection.options) do
    local text = string.format("%i", e)
    gfx.text_ex(text, x_answers, start_answers + line, 1, 0, gfx.COLOR_TRUE_WHITE, 1)
    line += 20
  end

  gfx.circ_fill(
    x_answers - 10,
    5 + start_answers + (self.index_option * 20),
    3,
    gfx.COLOR_GREEN
  )
end

function Footer:down()
  if self.selection == nil then
    return
  end

  local option = self.index_option + 1

  if option >= #self.selection.options then
    option = 0
  end
  self.index_option = option
end

function Footer:up()
  if self.selection == nil then
    return
  end


  local option = self.index_option - 1

  if option < 0 then
    option = #self.index_option
  end

  self.index_option = option
end

function Footer:update()
  if input.key_pressed(input.KEY_DOWN) then
    self:down()
  end

  if input.key_pressed(input.KEY_UP) then
    self:up()
  end
end

function Footer:select()
  -- local index = math.random(#problems)
  local index = 1
  self.selection = problems[index]
end

return Footer
