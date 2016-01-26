require 'src/blog'
require 'test/data_mock'
--local inspect = require 'inspect'

describe('Blog entry operations', function()
	it('should create a entry', function()
		local e = Entry:new('slug', 'Title', 1451937829,
		{ 'tag1', 'tag2' }, 'file')

		assert(e)
		assert(e.slug == 'slug')
		assert(e.title == 'Title')
		assert(e.date == 1451937829)
		assert(e.tags)
		assert(#e.tags == 2)
		assert(e.tags[1] == 'tag1')
		assert(e.tags[2] == 'tag2')
		assert(e.contentDest == 'file')
	end)

	it('should get some mock data', function()
		local entries = Data.scanEntries('.')
		assert(#entries > 0)
		for i = 1, #entries do
			assert(entries[i])
			assert(entries[i].slug == 'slug' .. i)
			assert(entries[i].title == 'Entry' .. i)
			assert(#entries[i].tags > 1)
			assert(entries[i].tags[1] == 'custom' .. i)
		end
	end)

	it('should read mock content', function()
		local entries = Data.scanEntries('.')
		assert(entries[1]:readContent() == entries[1].contentDest)
	end)
end)

