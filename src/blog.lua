Entry = {}

function Entry:new(slug, title, date, tags)
	self._index = self
	return setmetatable({
		slug = assert(slug),
		title = assert(title),
		date = assert(date),
		tags = assert(tags),
	}, self)
end

function Entry:getSlug() return self.slug end
function Entry:getTitle() return self.title end
function Entry:getDate() return self.date end
function Entry:getTags() return self.tags end

function Entry:readContent()
end

