local bz2 = require("bz2")

math.randomseed(42)
local data_stream = {}
for i = 1, 1000 do
	data_stream[#data_stream + 1] = tostring(math.random()) .. "\n"
end

local filename = os.tmpname()
local out = assert(bz2.openWrite(filename))
for _, item in ipairs(data_stream) do
	assert(out:write(item))
end
assert(out:close())

local input = assert(bz2.openRead(filename))
for _, item in ipairs(data_stream) do
	local read = assert(input:read(#item))
	assert(#read == #item, "Data length mismatch: expected " .. #item .. " got " .. #read)
	assert(read == item, "Data item mismatch")
end
assert(nil == input:read(1024), "Unexpected data found")
input:close()

os.remove(filename)

-- Test stream ops
local compressor = assert(bz2.initCompress())
local compressed = {}
for _, item in ipairs(data_stream) do
	local val = assert(compressor:update(item))
	if #val > 0 then
		-- Avoid feeding in empty chunks since BZ2 accumulates quite a bit
		compressed[#compressed + 1] = val
	end
end
-- Finish stream
compressed[#compressed + 1] = assert(compressor:update(nil))
assert(compressor:close())

-- ADD DUMMY DATA FOR CHECK
local DUMMY_TRAILER = "I AM A DUMMY TRAILER VALUE"
compressed[#compressed] = compressed[#compressed] .. DUMMY_TRAILER

local decompressor = assert(bz2.initDecompress())
local decompressed = {}
local finished
local trailer = {}
for _, item in ipairs(compressed) do
	if finished then
		trailer[#trailer + 1] = item
	else
		local ret, err = decompressor:update(item)
		if not ret then
			error(err .. " - for item " .. _ .. " of length " .. #item)
		end
		decompressed[#decompressed + 1] = ret
		if err then
			finished = true
			if err > 0 then
				trailer[#trailer + 1] = item:sub(-err)
			end
		end
	end
end
assert(decompressor:close())

local data = table.concat(data_stream)
decompressed = table.concat(decompressed)
assert(#decompressed == #data, "Expected " .. #data .. " but got " .. #decompressed)
assert(decompressed == data, "Data mismatch on decompression")

trailer = table.concat(trailer)
assert(DUMMY_TRAILER == trailer, "Expected trailer: [[" .. DUMMY_TRAILER .. "]] got [[" .. trailer .. "]]")


