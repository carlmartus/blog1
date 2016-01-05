local turbo = require 'turbo'
local Data = require 'src/data_fs'
local inspect = require 'inspect'


local allEntries

--==============================================================================
-- Utility
--==============================================================================

local function writeHeader(req, code, contentType, contentLength)
    req:write("HTTP/1.1 "..code.."\r\n")

	if contentType then
		print('Sending content type')
		req:write("Content-Type: "..contentType.."\r\n")
	end

	if contentLength then
		print('Sending content length')
		req:write("Content-Length: "..contentLength.."\r\n")
	end

	req:write("\r\n")
end


--==============================================================================
-- Requests
--==============================================================================

-- Root
local RequestRoot = class('RequestRoot', turbo.web.RequestHandler)
function RequestRoot:get()
	self:write('Test')
end

-- Article
local RequestArticle = class('RequestArticle', turbo.web.RequestHandler)
function RequestArticle:get(slug)
	self:write('Looking for slug ['..slug..']')
end

-- 404
local Request404 = class('Request404', turbo.web.RequestHandler)
function Request404:get(url)
	self:set_status(404)

	self:write('404 Not found('..url..')')
end


--==============================================================================
-- Entry point
--==============================================================================

local function main()
	local app = turbo.web.Application({
		{ '^/$', RequestRoot },
		{ '^/articles/(.+)$', RequestArticle },
		{ '^.*$', Request404 },
	})
	app:listen(8080)

	turbo.ioloop.instance():start()
end

-- Start program
main()

