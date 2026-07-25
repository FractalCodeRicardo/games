local Constants = require("constants")
function Clone(tbl, override_values)
  local new = {}

  for k, v in pairs(tbl) do
    new[k] = v
  end

  for k, v in pairs(override_values) do
    new[k] = v
  end

  return new
end

function AppendAll(tbl, values)
  for i = 1, #values do
    table.insert(tbl, values[i])
  end
end

function PrintTable(tbl)
  for k, v in pairs(tbl) do
    print(k .. " -> " .. v .. "\n")
  end
end

function GetBounds(entity)
  return  {
    x1 = entity.x,
    x2 = entity.x + entity.w * Constants.SPRITE_SIZE,
    y1 = entity.y,
    y2 = entity.y + entity.h * Constants.SPRITE_SIZE,
  }
end

function Collides(e1, e2)
 local b1 = GetBounds(e1)
 local b2 = GetBounds(e2)

 -- left
  if (b1.x2 <= b2.x1) then
    return false
  end

  -- right
  if (b1.x1 >= b2.x2) then
    return false
  end

  -- up
  if (b1.y2 <= b2.y1) then
    return false
  end

  -- down
  if (b1.y1 >= b2.y2) then
    return false
  end

  print(string.format("%f %f %f %f %f %f %f %f",

  b1.x1,b1.x2, b1.y1, b1.y2,
  b2.x1,b2.x2, b2.y1, b2.y2
))

  return true
end

function GetCollidedEntity(entity, entities)
  for i,e in pairs(entities) do
    print(e)
    if Collides(entity, e) then
      return e
    end
  end

  return nil
end

function CollidesWith(entity, entities)
  local e = GetCollidedEntity(entity, entities)
  return e ~= nil
end
