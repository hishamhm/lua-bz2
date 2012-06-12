local ltn12 = require("ltn12")
local bz2_ltn12 = require("bz2.ltn12")

math.randomseed(42)
local data_stream = {}
for i = 1, 1000 do
	data_stream[#data_stream + 1] = tostring(math.random()) .. "\n"
end
local data = table.concat(data_stream)

local filename = os.tmpname()
local source = ltn12.source.string(data) 
local sink = bz2_ltn12.sink.file(filename)

assert(ltn12.pump.all(source, sink))

local source = bz2_ltn12.source.file(filename)
local sink, result_stream = ltn12.sink.table()

assert(ltn12.pump.all(source, sink))
local result = table.concat(result_stream)
assert(#data == #result, "Length does not match, expected:" .. #data .. " got " .. #result)
assert(data == result, "Data does not match")

os.remove(filename)

-- Test round-trim equality
local source = ltn12.source.string(data)
local sink, result_stream = ltn12.sink.table()

local filter = ltn12.filter.chain(
	bz2_ltn12.filter.compress(),
	bz2_ltn12.filter.decompress()
)
sink = ltn12.sink.chain(filter, sink)

assert(ltn12.pump.all(source, sink))

assert(#data == #result, "Length does not match, expected:" .. #data .. " got " .. #result)
assert(data == result, "Data does not match")

-- Tests mixed handling
local filename = os.tmpname()
local source = ltn12.source.string(data)
local sink = ltn12.sink.file(io.open(filename, "wb"))

local filter = bz2_ltn12.filter.compress()
sink = ltn12.sink.chain(filter, sink)

assert(ltn12.pump.all(source, sink))

local source = ltn12.source.file(io.open(filename, "rb"))
local sink, result_stream = ltn12.sink.table()

local filter = bz2_ltn12.filter.decompress()

sink = ltn12.sink.chain(filter, sink)

assert(ltn12.pump.all(source, sink))

assert(#data == #result, "Length does not match, expected:" .. #data .. " got " .. #result)
assert(data == result, "Data does not match")

os.remove(filename)

