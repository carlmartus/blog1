local turbo = require 'turbo'
Data = require 'src/data_fs'
local io = require 'io'
--local inspect = require 'inspect'

PATH_CONTENT = 'content'

local allEntries
local templates = { partials={} }
local mustachePages = {
	'front', 'head', 'foot', 'missing', 'part_article',
}

--==============================================================================
-- Utility
--==============================================================================

local function createTemplate(fileName)
	local fd = io.open('templ/'..fileName..'.mustache', 'rb')
	local content = fd:read('*a')
	fd:close()

	return turbo.web.Mustache.compile(content)
end

local function readArticleList(arr)
	fixed = {}
	for i = 1, #arr do
		local addTags = {}
		for j = 1, #arr[i].tags do
			table.insert(addTags, {
				name=arr[i].tags[j],
				slug=string.lower(string.gsub(arr[i].tags[j], ' ', '-')),
			})
		end

		table.insert(fixed, {
			title=arr[i].title,
			date=arr[i].date,
			content=arr[i]:readContent(),
			tags=addTags,
		})
	end

	return fixed
end

local function renderTemplate(template, data, partials)
	return turbo.web.Mustache.render(template, data, partials)
end


--==============================================================================
-- Requests
--==============================================================================

-- Root
local RequestFront = class('RequestFront', turbo.web.RequestHandler)
function RequestFront:get()
	local selectedArticles = {}
	for i = 1, math.min(5, #allEntries) do
		--[[
		if not allEntries[i].contentData then
			allEntries[i].contentData = allEntries[i]:readContent()
		end
		]]--

		table.insert(selectedArticles, allEntries[i])
	end

	local part = readArticleList(selectedArticles)
	self:write(renderTemplate(templates.front, {
		articles=part,
	}, templates))
end

-- Article
local RequestArticle = class('RequestArticle', turbo.web.RequestHandler)
function RequestArticle:get(slug)
	local entry = nil

	for i = 1, #allEntries do
		if allEntries[i].slug == slug then
			entry = allEntries[i]
		end
	end

	if entry then
	else
	end
end

--=============================================================================
-- 404
--=============================================================================

local Request404 = class('Request404', turbo.web.RequestHandler)
function Request404:get(path)
	self:set_status(404)

	--self:write('404 Not found('..url..')')
	self:write(renderTemplate(templates.missing, {
		path=path,
	}, templates))
end


--==============================================================================
-- Entry point
--==============================================================================

local function main()
	allEntries = Data.scanEntries(PATH_CONTENT)

	for i = 1, #mustachePages do
		templates[mustachePages[i]] = createTemplate(mustachePages[i])
	end

	local app = turbo.web.Application({
		{ '^/$', RequestFront },
		{ '^/articles/(.+)$', RequestArticle },
		{ '^/(.*)$', turbo.web.StaticFileHandler, 'static/' },
		--{ '^.*$', Request404 },
	})
	app:listen(8080)

	turbo.ioloop.instance():start()
end

-- Start program
main()

