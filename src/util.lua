-- Utility functions
local cjson = require 'cjson'

function readFileRaw(path)
	local fd = io.open(path)
	local raw = fd:read('*a')
	fd:close()

	return raw
end

function readFileJson(path)
	return cjson.decode(readFileRaw(path))
end

