local JSON = require("json")
local FILE = require("file")
local M = {}
local res_file = "/tmp/mines-response.json"
local done_file = "/tmp/mines-done"



local function remove_files()
    FILE.remove(res_file)
    FILE.remove(done_file)
end

M.command = function(url, apikey, body)
    local command = string.format(
        'curl -sS %s ' ..
        '-H "Content-Type: application/json" ' ..
        '-H "Authorization: Bearer %s" ' ..
        ' -o ' .. res_file .. ' ' ..
        '-d %q',
        url,
        apikey,
        body
    )

    command = command .. ' && touch ' .. done_file .. " &"

    return command
end

M.get = function(url, apikey, body, callback)
    print("--- GET " .. url)
    if M.callback ~= nil then
        error("Only one request peer time for now")
    end

    remove_files()
    M.callback = callback
    local command = M.command(url, apikey, body)


    local result = os.execute(command)
    if result == nil then
        error("Error performing the request")
    end
end

M.update = function()
    if M.callback == nil then
        return
    end

    if not FILE.exists(done_file) then
        return
    end

    local content = FILE.read(res_file)
    local res = JSON.decode(content)

    local ok, err = pcall(function()
        M.callback(res)
    end)

    M.callback = nil
    remove_files()

    if not ok then
        error(err)
    end
end



return M
