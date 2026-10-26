local JSON = require("json")
local FILE = require("file")

local M = {}
M.requests = {}

local request_index = 0

local function response_file(id)
  return "/tmp/tetris-response-" .. id .. ".json"
end

local function done_file(id)
  return "/tmp/tetris-done-" .. id
end

local function remove_files(id)
  FILE.remove(response_file(id))
  FILE.remove(done_file(id))
end

local function new_id()
  request_index = request_index + 1
  return os.time() .. "-" .. request_index
end

M.command = function(url, apikey, body, opts, id)
  local r_file = response_file(id)
  local d_file = done_file(id)
  local options = {}
  for k, v in pairs(opts or {}) do
    options[k] = v
  end

  options.apiKeyHeader = options.apiKeyHeader or
      (string.format('Authorization: Bearer %s', apikey))

  if options.extraHeader == nil then
    options.extraHeader = ""
  else
    options.extraHeader = '-H "' .. options.extraHeader .. '" '
  end

  local command = string.format(
    'curl -sS %s ' ..
    '-H "Content-Type: application/json" ' ..
    '-H "' .. options.apiKeyHeader .. '" ' ..
    options.extraHeader .. ' ' ..
    ' -o ' .. r_file .. ' ' ..
    '-d %q',
    url,
    body
  )

  command = command .. ' && touch ' .. d_file.. " &"

  return command
end

M.add_request = function(callback)
  local id = new_id()
  table.insert(M.requests, { id = id, callback = callback })
  return id
end

M.get = function(url, apikey, body, opts, callback)
  print("GET " .. url)

  local reques_id = M.add_request(callback)
  local command = M.command(url, apikey, body, opts, reques_id)

  local result = os.execute(command)
  if result == nil then
    table.remove(M.requests)
    error("Error performing the request")
  end

  return reques_id
end

M.check_request = function(index)
  local request = M.requests[index]
  local d_file = done_file(request.id)
  local r_file = response_file(request.id)

  if not FILE.exists(d_file) then
    return
  end

  table.remove(M.requests, index)

  local content = FILE.read(r_file)
  local res = JSON.decode(content)
  remove_files(request.id)

  local ok, err = pcall(request.callback, res)
  if not ok then
    error(err)
  end
end

M.check_requests = function()
  for i = #M.requests, 1, -1 do
    M.check_request(i)
  end
end

M.update = function()
  M.check_requests()
end

return M
