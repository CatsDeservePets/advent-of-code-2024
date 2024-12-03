---@type boolean
local DEBUG = false
---@type string
local file_name = DEBUG and "./example.txt" or "./input.txt"

---@param file_path string
---@return string
local function read_file(file_path)
	local f = assert(io.open(file_path))
	local input = f:read("*a")
	f:close()
	return input
end

---Returns the sum of valid mul instructions with format `mul(X,Y)`
---@param memory string
---@return number
local function exec_multiplications(memory)
	local total = 0
	for n1, n2 in memory:gmatch("mul%((%d+),(%d+)%)") do
		total = total + tonumber(n1) * tonumber(n2)
	end
	return total
end

---Removes disabled instructions between `don't()` and `do()`
---@param memory string
---@return string
---@return integer count
local function sanitize_memory(memory)
	return string.gsub(memory, "don%'t%(%).-do%(%)", "")
end

local memory = read_file(file_name)

--- Day 3: Mull It Over ---
print(exec_multiplications(memory))

--- Part Two ---
memory = sanitize_memory(memory)
print(exec_multiplications(memory))
