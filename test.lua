require("bz2")

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

local input = assert(bz2.open(filename))
for _, item in ipairs(data_stream) do
	local read = assert(input:read(#item))
	assert(#read == #item, "Data length mismatch: expected " .. #item .. " got " .. #read)
	assert(read == item, "Data item mismatch")
end
assert(nil == input:read(1024), "Unexpected data found")
input:close()

b = bz2.open(filename)
for _, item in ipairs(data_stream) do
	local read = b:getline()
	assert(#read == #item, "Data length mismatch: expected " .. #item .. " got " .. #read)
	assert(read == item, "Data item mismatch")
end
assert("" == b:getline(), "Expected final empty line")
assert(nil == b:getline(), "Unexpected data found")
b:close()

local i = 1

local b = assert(bz2.open(filename))
for read in b:lines() do
	local item = data_stream[i]
	i = i + 1
	if i == #data_stream + 2 then
		-- Final terminator
		item = ""
	else
		-- Add in nul terminator if not final
		read = read .. "\n"
	end
	assert(#read == #item, "Data length mismatch: expected " .. #item .. " got " .. #read)
	assert(read == item, "Data item mismatch")
end
assert(nil == b:getline(), "Unexpected data found")
b:close()

os.remove(filename)

