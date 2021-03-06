require 'src/util'
local turbo = require 'turbo'
Data = require 'src/data_fs'
local io = require 'io'
--local inspect = require 'inspect' -- DEBUG

PATH_CONTENT = 'content'

local allEntries
local templates = { partials={} }
local mustachePages = {
	'front', 'head', 'foot', 'missing', 'part_article', 'article', 'hosted',
}

--==============================================================================
-- Web utility
--==============================================================================

local function createTemplate(fileName)
	local fd = io.open('templ/'..fileName..'.mustache', 'rb')
	local content = fd:read('*a')
	fd:close()

	return turbo.web.Mustache.compile(content)
end

local function readArticle(entry, link)
	local addTags = {}
	for j = 1, #entry.tags do
		table.insert(addTags, {
			name=entry.tags[j],
			slug=string.lower(string.gsub(entry.tags[j], ' ', '-')),
		})
	end

	local ret = {
		title=entry.title,
		date=entry.date,
		content=entry:readContent(),
		slug=entry.slug,
		tags=addTags,
	}

	if link then
		ret.link = true
	end

	return ret
end

local function readArticleList(arr, link)
	fixed = {}
	for i = 1, #arr do
		table.insert(fixed, readArticle(arr[i], link))
	end

	return fixed
end

local function renderTemplate(template, data, partials)
	return turbo.web.Mustache.render(template, data, partials)
end

local function sendTemplate(req, template, data)
	req:write(renderTemplate(template, data, templates))
end


--=============================================================================
-- 404
--=============================================================================

local function send404(req)
	req:set_status(404)
	sendTemplate(self, templates.missing, { path=path })
end

local Request404 = class('Request404', turbo.web.RequestHandler)
function Request404:get(path)
	send404(self)
end


--==============================================================================
-- Requests
--==============================================================================

-- Root
local RequestFront = class('RequestFront', turbo.web.RequestHandler)
function RequestFront:get()
	local selectedArticles = {}
	--for i = 1, math.min(5, #allEntries) do
	for i = 1, #allEntries do
		table.insert(selectedArticles, allEntries[i])
	end

	local part = readArticleList(selectedArticles, true)

	sendTemplate(self, templates.front, { articles=part })
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
		local article = readArticle(entry, true)
		local send = {
			title = article.title,
			article={article},
		}

		sendTemplate(self, templates.article, send)
	else
		send404(self)
	end
end

-- Tag
local RequestTag = class('RequestTag', turbo.web.RequestHandler)
function RequestTag:get(tag)
	local selectedArticles = {}
	for i = 1, #allEntries do
		local hasTag = false
		for j = 1, #allEntries[i].tags do
			if allEntries[i].tags[j] == tag then
				hasTag = true
			end
		end

		if hasTag then
			table.insert(selectedArticles, allEntries[i])
		end
	end

	local part = readArticleList(selectedArticles, true)

	sendTemplate(self, templates.front, { articles=part })
end

-- Hosted
local RequestHosted = class('RequestHosted', turbo.web.RequestHandler)
function RequestHosted:get()
	local json = readFileJson('hosted.json')

	-- Prepare some fields for mustache
	for a = 1, #json.items do
		for b = 1, #json.items[a].links do
			link = json.items[a].links[b]
			json.items[a].links[b] = {
				name = link[1],
				href = link[2],
			}
		end
	end

	sendTemplate(self, templates.hosted, json)
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
		{ '^/tags/(.+)$', RequestTag },
		{ '^/hosted$', RequestHosted },
		{ '^/projects$', RequestHosted },
		{ '^/(.*)$', turbo.web.StaticFileHandler, 'static/' },
		--{ '^.*$', Request404 },
	})
	app:listen(8083, '127.0.0.1')

	turbo.ioloop.instance():start()
end

-- Start program
main()

