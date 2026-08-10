local Constants = require("constants")
local Menu = {}
local cursor_pos = "start"

function Menu.draw()

  local x = Constants.get_screen_width() / 2 - 40 / 2.
  local y = Constants.get_screen_height() * 0.25

  gfx.text_ex("Let's Code!", x - 35, y - 20, 2,0, gfx.COLOR_GREEN, 1)
  gfx.spr(1, x + 4, Constants.get_screen_height() * 0.10)

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
 if (input.key_pressed(input.KEY_UP)) then
   Menu.toggle_options()
   sfx.play("jump")
 end

 if (input.key_pressed(input.KEY_DOWN)) then
   Menu.toggle_options()
   sfx.play("jump")
 end

 if (input.key_pressed(input.KEY_SPACE)) then
   if (cursor_pos == "quit") then
     usagi.quit()
   else
     sfx.play("coin")
     Menu.on_start()
   end
 end
end

return Menu
