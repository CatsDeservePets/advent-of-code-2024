local DEBUG = false
local file_name = DEBUG and "./example.txt" or "./input.txt"

---@param file_path string
---@return string[][]
local function parse_input(file_path)
	local map = {}
	for line in io.lines(file_path) do
		local tmp = {}
		for match in line:gmatch(".") do
			table.insert(tmp, match)
		end
		table.insert(map, tmp)
	end
	return map
end

---Creates a deep copy of a table to avoid reference issues
function table.copy(t)
	local t2 = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			t2[k] = table.copy(v)
		else
			t2[k] = v
		end
	end
	return t2
end

---Extracts `antennas` out of a map
---@param map string[][] --Map of antennas
---@return table<string, [number, number][]> --A dict of frequencies and their positions
local function find_antennas(map)
	local antenna_spots = {}
	for i, row in ipairs(map) do
		for j, col in ipairs(row) do
			if col ~= "." then
				if not antenna_spots[col] then
					antenna_spots[col] = {}
				end
				table.insert(antenna_spots[col], { i, j })
			end
		end
	end
	return antenna_spots
end

---Calculates `antinodes` inside a map
---An `antinode` is a point in line with two antennas off the same
---frequency. In the original model, it only occurs when one
---antenna is twice as far from the point as the other.
---In the updated model, antinodes appear at any collinear
---position, including the antennas themselves.
---@param map string[][] --Map of antennas
---@param updated_model? boolean --Whether to use the newer model, defaults to false
---@return string[][] --Updated map with `antinodes` marked as `#`
---@return number --Amount of unique locations containing `antinodes`
local function calculate_signal(map, updated_model)
	local count = 0
	local tmp = table.copy(map)
	local spots = find_antennas(map)
	for _, antennas in pairs(spots) do
		for i = 1, #antennas - 1 do
			for j = i + 1, #antennas do
				---@param p1 [number, number]
				---@param p2 [number, number]
				local function mark_antinode(p1, p2)
					local r = 2 * p1[1] - p2[1]
					local c = 2 * p1[2] - p2[2]
					if r >= 1 and r <= #tmp and c >= 1 and c <= #tmp[1] then
						if tmp[r][c] ~= "#" then
							tmp[r][c] = "#"
							count = count + 1
						end
						-- Mark all collinear positions
						if updated_model then
							mark_antinode({ r, c }, p2)
							mark_antinode({ r, c }, p1)
						end
					end
				end
				-- Mark antinodes on both sides of the antenna pair line
				local pos1, pos2 = antennas[i], antennas[j]
				mark_antinode(pos1, pos2)
				mark_antinode(pos2, pos1)
			end
		end
		-- In the updated model, all antennas in the group are antinodes
		if updated_model and #antennas >= 2 then
			for _, antenna in ipairs(antennas) do
				local r, c = antenna[1], antenna[2]
				if tmp[r][c] ~= "#" then
					tmp[r][c] = "#"
					count = count + 1
				end
			end
		end
	end
	return tmp, count
end

local map = parse_input(file_name)

--- Day 8: Resonant Collinearity ---
local _, count = calculate_signal(map)
print(count)

--- Part Two ---
local _, count2 = calculate_signal(map, true)
print(count2)
