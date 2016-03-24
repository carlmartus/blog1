-- Utility functions
local cjson = require 'cjson'

function fileExists(path)
	local f = io.open(path, "r")

	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function readFileRaw(path)
	local fd = io.open(path)
	local raw = fd:read('*a')
	fd:close()

	return raw
end

function readFileJson(path)
	return cjson.decode(readFileRaw(path))
end

