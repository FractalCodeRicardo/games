local Constants = require("constants")
local Footer = {}
Footer.__index = Footer

local start = Constants.BOARD_SIZE * Constants.CELL_SIZE + 8
local start_answers = start + 30
local x_answers = 150

local problems = usagi.read_json("problems.json")

function Footer:new()
  local instance = setmetatable({}, Footer)
  instance.selection = nil
  instance.selected_index = 1
  instance.index_option = 0
  instance.state = "waiting"
  instance.dt = 0
  instance:select()
  return instance
end


function Footer:draw_problem()
  if self.selection == nil then
    return
  end

  self:draw_border()
  self:draw_description()
  self:draw_answers()
end

function Footer:draw_waiting()
  self:draw_border()
  gfx.spr_ex(1, 15, start_answers,
  false,
  false, self.dt, 0, 1
  )

  gfx.text_ex("Let's Code!",
    50,
    start_answers,
    2,
    0,
    gfx.COLOR_WHITE,
    1)

end

function Footer:draw()
  if self.state == "waiting" then
    self:draw_waiting()
  else
    self:draw_problem()
  end
end

function Footer:draw_border()
  local w =usagi.GAME_W - 10
  local h = 45 + #self.selection.options * 21
  gfx.rect_fill(5, start - 5, w, h, gfx.COLOR_BLACK)
  gfx.rect_ex(5, start - 5, w, h, 1, gfx.COLOR_PEACH)
end

function Footer:draw_description()
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

function Footer:update_waiting(dt)
  self.dt += dt
end

function Footer:update_problem()
  if input.key_pressed(input.KEY_DOWN) then
    self:down()
    sfx.play("jump")
  end

  if input.key_pressed(input.KEY_UP) then
    self:up()
    sfx.play("jump")
  end

  if input.key_pressed(input.KEY_SPACE) then
    self:solve()
    sfx.play("coin")
  end
end

function Footer:solve()
  local right = self.selection.correct == self.index_option

  self.on_solve(right)
  self.state = "waiting"
end

function Footer:update(dt)
  if self.state == "waiting" then
    self:update_waiting(dt)
  else
    self:update_problem()
  end
end

function Footer:select()
  -- local index = math.random(#problems)
  local index = 1
  self.selection = problems[index]
end

function Footer:show_problem(on_solve)
  self.on_solve = on_solve
  local index = self.selected_index + 1

  if index > #problems then
    index = 1
  end

  self.selected_index = index
  self.selection = problems[index]
  self.state = "solving"
end

function Footer:user_is_solving()
  return self.state == "solving"
end

return Footer
