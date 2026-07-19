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
