local M = {}
local enabled = false

M.jump = function()
    if not enabled then return end


    sfx.play("jump")
end

M.coin = function()
    if not enabled then return end

    sfx.play("coin")
end

M.explosion = function()
    if not enabled then return end

    sfx.play("explosion")
end

M.flag = function()
    if not enabled then return end

    sfx.play("flag")
end

M.error = function()
    if not enabled then return end

    sfx.play("error")
end

return M
