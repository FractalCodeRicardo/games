local Constants = {}

Constants.BOARD_SIZE = 5
Constants.CELL_SIZE = 50
Constants.SPRITE_SIZE = 32
Constants.MINES = 2
Constants.BOTTOM_SIZE = 200
Constants.SCORE_SIZE = 110

Constants.get_screen_height = function()
  return Constants.BOARD_SIZE * Constants.CELL_SIZE + Constants.BOTTOM_SIZE;
end


Constants.get_screen_width = function()
  return Constants.BOARD_SIZE *
      Constants.CELL_SIZE +
      Constants.SCORE_SIZE;
end

return Constants
