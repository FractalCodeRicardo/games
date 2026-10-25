local M = {}

M.exists = function(name)
    local f = io.open(name, "r")

    if f then
        f:close()
        return true
    else
        return false
    end
end


M.remove = function(name)
    if M.exists(name) then
        os.remove(name)
    end
end

M.read = function(filename)
    local file = io.open(filename, "r")

    if not file then
        return nil, "Could not open file"
    end

    local content = file:read("*a")
    file:close()

    return content
end

M.write= function(filename, content)
    local file = io.open(filename, "w")

    if not file then
        return false, "Could not open file"
    end

    file:write(content)
    file:close()

    return true
end

return M
