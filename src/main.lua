local turbo = require 'turbo'
local Data = require 'src/data_fs'
local inspect = require 'inspect'

print(inspect(Data.scanEntries('../blog0/content')))

