local Constants = require("constants")
local Menu = {}
local cursor_pos = "start"

Menu.on_start = function ()
end

function Menu.draw()

  local mt = usagi.measure_text("FROGGER")
  local x = Constants.WIDTH / 2 - mt / 2.
  local y = Constants.HEIGHT * 0.25
  gfx.text("FROGEER", x, y, gfx.COLOR_GREEN)
  gfx.spr(15, x + 10, Constants.HEIGHT * 0.10)


  gfx.text("Start", x + 5, y + 40, gfx.COLOR_WHITE)
  gfx.text("Quit", x + 7, y + 60, gfx.COLOR_WHITE)

  local cursor_y = 0

  if (cursor_pos == "start") then
    cursor_y = y + 45
  else
    cursor_y = y + 65
  end

  gfx.circ_fill(x - 10, cursor_y, 3, gfx.COLOR_PEACH)
end

function Menu.toggle_options()
  if (cursor_pos == "start") then
    cursor_pos = "quit"
    return
  end

  if (cursor_pos == "quit") then
    cursor_pos = "start"
  end

end

function Menu.update()
 if (input.key_pressed(input.KEY_J)) then
   Menu.toggle_options()
 end

 if (input.key_pressed(input.KEY_K)) then
   Menu.toggle_options()
 end

 if (input.key_pressed(input.KEY_SPACE)) then
   if (cursor_pos == "quit") then
     usagi.quit()
   else
     Menu.on_start()
   end
 end
end


return Menu
