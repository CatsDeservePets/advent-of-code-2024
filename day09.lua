local DEBUG = false
local file_name = DEBUG and "./example.txt" or "./input.txt"

---@class segment
---@field start number
---@field length number
---@field id? string

---@param file_path string
---@return string
local function read_file(file_path)
	local f = assert(io.open(file_path))
	local input = f:read("*a")
	f:close()
	return input
end

---@param input string
---@return string[]
local function parse(input)
	local disk_map = {}
	local id = 0
	local is_file = true
	for char in input:gmatch("%d") do
		local val = is_file and id or "."
		for _ = 1, char do
			table.insert(disk_map, val)
		end
		if is_file then
			id = id + 1
		end
		-- Digits alternate between indicating file length and length of free space
		is_file = not is_file
	end
	return disk_map
end

---@param t table
local function visualise(t)
	print(table.concat(t, ""))
end

---Moves individual file blocks to the leftmost free spaces
---@param disk_map string[]
local function align_blocks_left(disk_map)
	if DEBUG then
		visualise(disk_map)
	end

	for i = #disk_map, 1, -1 do
		if disk_map[i] ~= "." then
			for j = 1, i do
				if disk_map[j] == "." then
					-- Swap file and free space
					disk_map[i], disk_map[j] = disk_map[j], disk_map[i]
					if DEBUG then
						visualise(disk_map)
					end
					break
				end
			end
		end
	end
end

---Extracts file segments and free space segments from the disk map
---@param disk_map string[]
---@return segment[] files
---@return segment[] free
local function extract_segments(disk_map)
	local files, free = {}, {}
	local i = 1
	while i <= #disk_map do
		local start = i
		local is_file = disk_map[i] ~= "."
		while i <= #disk_map and disk_map[i] == disk_map[start] do
			i = i + 1
		end
		local segment = { start = start, length = i - start }
		if is_file then
			segment.id = disk_map[start]
			table.insert(files, segment)
		else
			table.insert(free, segment)
		end
	end
	return files, free
end

---Moves files to the leftmost span of free space blocks
---@param disk_map string[]
local function align_files_left(disk_map)
	local files, free_blocks = extract_segments(disk_map)

	-- Process in order of decreasing file ID
	table.sort(files, function(a, b)
		return a.id > b.id
	end)

	if DEBUG then
		visualise(disk_map)
	end
	for _, file in ipairs(files) do
		for free_idx = 1, #free_blocks do
			local free_block = free_blocks[free_idx]
			if free_block.length >= file.length and free_block.start + free_block.length <= file.start then
				-- Move file
				for offset = 0, file.length - 1 do
					disk_map[free_block.start + offset] = file.id
					disk_map[file.start + offset] = "."
				end
				if DEBUG then
					visualise(disk_map)
				end
				-- Update free span
				free_block.start = free_block.start + file.length
				free_block.length = free_block.length - file.length
				if free_block.length == 0 then
					table.remove(free_blocks, free_idx)
				end
				break
			end
		end
	end
end

---Calculates the `checksum` of the disk map
--- The checksum is the `sum` of `multiplying each block's
--- position by` its `file ID`, ignoring free spaces.
---@param disk_map string[]
---@return number checksum
local function calculate_checksum(disk_map)
	local checksum = 0
	for position, block in ipairs(disk_map) do
		if block ~= "." then
			checksum = checksum + ((position - 1) * tonumber(block))
		end
	end
	return checksum
end

local input = read_file(file_name)

--- Day 9: Disk Fragmenter ---
local disk_map = parse(input)
align_blocks_left(disk_map)
print(calculate_checksum(disk_map))

--- Part Two ---
local disk_map2 = parse(input)
align_files_left(disk_map2)
print(calculate_checksum(disk_map2))
