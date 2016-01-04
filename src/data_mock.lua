require 'src/blog'

local Data = {}

function Data.readContent(entry)
	return entry.contentDest
end

function Data.scanEntries(dest)
	local list = {}
	for i = 1, 3 do
		local e = Entry:new(
			'slug' .. i,
			'Entry' .. i,
			1451937829,
			{ 'custom' .. i, 'tag1', 'tag2' },
			dest .. '/file' .. i)
		table.insert(list, e)
	end

	return list
end

return Data

