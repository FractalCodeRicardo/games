local Constants = require("constants")
local M = {}


M.split = function(inputstr, sep)
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

M.cell_as_string = function(cell)
    local value = "x"

    if cell.open then
        value = cell.value .. ""
    end

    if cell.flag then
        value = "f"
    end

    return value
end

M.board_as_string = function(cells)
    local size = Constants.BOARD_SIZE
    local board = ""
    for y = 1, size do
        local line = ""
        for x = 1, size do
            local cell = cells[y][x]
            local value = M.cell_as_string(cell)

            line = line .. value

            if x ~= size then
                line = line .. ","
            end
        end

        board = board .. line
        if y ~= size then
            board = board .. "\n"
        end
    end

    return board
end

return M
