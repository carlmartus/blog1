require 'src/blog'
local fs = require 'lfs'
local cjson = require 'cjson'
local inspect = require 'inspect'
local cmark = require 'cmark'

local Data = {}

function readFileRaw(path)
	local fd = io.open(path)
	local raw = fd:read('*a')
	fd:close()

	return raw
end

function Data.readContent(entry)
	local raw =  readFileRaw(entry.contentDest)
	local doc = cmark.parse_document(raw, string.len(raw), cmark.OPT_DEFAULT)
	local html = cmark.render_html(doc, cmark.OPT_DEFAULT)

	return html
end

local function makeEntryFromDirectory(path, date)
	local raw = readFileRaw(path..'/meta.json', 'r')

	local json = cjson.decode(raw)

	if not json.longTitle then return end
	if not json.shortTitle then return end
	if not json.tags then return end

	local slug = string.lower(string.gsub(json.shortTitle, ' ', '-'))

	return Entry:new(slug, json.longTitle, date, json.tags, path..'/content.md')
end

local function parseDate(msg)
	local ye, mo, da, ho, mi = string.match(msg,
		'(%d+)-(%d+)-(%d+)-(%d+)-(%d+)')

	if ye and mo and da and ho and mi then
		return ye..'-'..mo..'-'..da..' '..ho..':'..mi
	end

	return nil
end

function Data.scanEntries(dest)
	local list = {}
	for file in lfs.dir(dest) do
		local date = parseDate(file)

		if date then
			local path = dest..'/'..file
			local entry = makeEntryFromDirectory(path, date)
			if entry then
				table.insert(list, entry)
			end
		end
	end

	table.sort(list, function(a, b)
		return a.date > b.date
	end)

	return list
end

return Data


