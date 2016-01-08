Entry = {}

function Entry:new(slug, title, date, tags, contentDest)
	self.__index = self
	return setmetatable({
		slug = assert(slug),
		title = assert(title),
		date = assert(date),
		tags = assert(tags),
		contentDest = assert(contentDest),
	}, self)
end

function Entry:readContent()
	return Data.readContent(self)
end

