require 'src/blog'
local inspect = require 'inspect'

describe('Blog entry operations', function()
	it('should create a entry', function()
		local e = Entry:new('slug', 'Title', 1451937829,
		{ 'tag1', 'tag2' }, nil)

		assert(e)
		assert(e.slug == 'slug')
		assert(e.title == 'Title')
		assert(e.date == 1451937829)
		assert(e.tags)
		assert(#e.tags == 2)
		assert(e.tags[1] == 'tag1')
		assert(e.tags[2] == 'tag2')
	end)
end)

