local turbo = require 'turbo'
local Data = require 'src/data_fs'
local io = require 'io'

PATH_CONTENT = 'content'

local allEntries
local templates = { partials={} }

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

local function createTemplate(fileName)
	local fd = io.open('templates/'..fileName..'.mustache', 'rb')
	local content = fd:read('*a')
	fd:close()

	return turbo.web.Mustache.compile(content)
end

local function renderTemplate(template, data, partials)
	return turbo.web.Mustache.render(template, data, partials)
end


--==============================================================================
-- Requests
--==============================================================================

-- Root
local RequestRoot = class('RequestRoot', turbo.web.RequestHandler)
function RequestRoot:get()
	self:write(renderTemplate(templates.front, {
		title='Front',
	}, templates))
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
	allEntries = Data.scanEntries(PATH_CONTENT)

	templates.front = createTemplate('front')
	templates.head = createTemplate('head')
	templates.foot = createTemplate('foot')

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

