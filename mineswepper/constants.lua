local Constants = {}

Constants.BOARD_SIZE = 10
Constants.CELL_SIZE = 35
Constants.SPRITE_SIZE = 32
Constants.MINES = 10
Constants.BOTTOM_SIZE = 200
Constants.SCORE_SIZE = 110
Constants.SECONDS = 5 * 60

Constants.get_screen_height = function()
  return Constants.BOARD_SIZE * Constants.CELL_SIZE + Constants.BOTTOM_SIZE;
end


Constants.get_screen_width = function()
  return Constants.BOARD_SIZE *
      Constants.CELL_SIZE +
      Constants.SCORE_SIZE;
end

return Constants
