local constants = require("constants")
local map = {}

local function create_row(value)
  local row = {}
  for x = 1, constants.SPRITE_WIDTH do
    row[x] = value
  end

  return row
end

local function create_tiles()
  local tiles = {}

  for y = 1, constants.SPRITE_HEIGHT do
    local row = create_row(0)
    table.insert(tiles, row)
  end

  tiles[1] = create_row(1)
  tiles[constants.SPRITE_HEIGHT] = create_row(1)

  tiles[constants.SPRITE_HEIGHT-1] = create_row(2)
  tiles[constants.SPRITE_HEIGHT-2] = create_row(2)
  tiles[constants.SPRITE_HEIGHT-3] = create_row(2)
  tiles[constants.SPRITE_HEIGHT-4] = create_row(2)
  tiles[constants.SPRITE_HEIGHT-5] = create_row(2)

  tiles[constants.SPRITE_HEIGHT-6] = create_row(1)

  tiles[constants.SPRITE_HEIGHT-6-1] = create_row(3)
  tiles[constants.SPRITE_HEIGHT-6-2] = create_row(3)
  tiles[constants.SPRITE_HEIGHT-6-3] = create_row(3)
  tiles[constants.SPRITE_HEIGHT-6-4] = create_row(3)
  tiles[constants.SPRITE_HEIGHT-6-5] = create_row(3)
  return tiles
end

map.tiles = create_tiles()

function map:draw ()
  for y = 1, constants.SPRITE_HEIGHT do
    for x = 1, constants.SPRITE_WIDTH do
      local sx = (x-1) * constants.SPRITE_SIZE;
      local sy = (y-1) * constants.SPRITE_SIZE;
      local tile = self.tiles[y][x]

      if (tile > 0) then
        gfx.spr(tile,sx, sy)
      end
    end
  end
end

return map;
