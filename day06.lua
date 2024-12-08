local DEBUG = false
local file_name = DEBUG and "./example.txt" or "./input.txt"

---@class position
---@field row number
---@field col number

---@type table<number, { row: number, col: number, symbol: string }>
local DIRECTIONS = {
	{ row = -1, col = 0 }, -- Up
	{ row = 0, col = 1 }, -- Right
	{ row = 1, col = 0 }, -- Down
	{ row = 0, col = -1 }, -- Left
}

---@param file_path string
---@return string[][], position
local function parse_input(file_path)
	local map = {}
	local start_pos
	local i = 1
	for line in io.lines(file_path) do
		local row = {}
		for j = 1, #line do
			local value = line:sub(j, j)
			row[j] = value
			if value == "^" then
				start_pos = { row = i, col = j }
			end
		end
		map[i] = row
		i = i + 1
	end
	return map, start_pos
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

---@class iterateOptions
---@field callback? fun(map: string[][], pos: position, new_pos: position)
---@field direction_idx? number

---Iterates over the given map
---@param map string[][] --The `map` grid
---@param start position --The starting position
---@param opts? iterateOptions Optional parameters:
--- - callback (function): A function that gets executed every iteration. When it returns anything other than nil the iteration stops.
--- - direction_idx (number): Index of the initial direction, defaults to `1` (up)
---@return string[][] --Modified `map`
---@return boolean --Whether a loop has been detected
local function iterate(map, start, opts)
	opts = opts or {}
	local callback = opts.callback
	local dir_idx = opts.direction_idx or 1

	---@type position
	local pos = { row = start.row, col = start.col }

	local tmp = table.copy(map)
	tmp[pos.row][pos.col] = "X"

	local visited_states = {}
	local has_loop = false

	while true do
		local state_key = pos.row .. "," .. pos.col .. "," .. dir_idx
		if visited_states[state_key] then
			has_loop = true
			break
		end
		visited_states[state_key] = true

		local direction = DIRECTIONS[dir_idx]
		local new_row = pos.row + direction.row
		local new_col = pos.col + direction.col

		if new_row < 1 or new_row > #tmp or new_col < 1 or new_col > #tmp[1] then
			break
		end

		if tmp[new_row][new_col] == "#" then
			-- Obstacle encountered, turn right
			dir_idx = (dir_idx % #DIRECTIONS) + 1
		else
			-- Otherwise, move forward
			if callback then
				local continue = callback(tmp, pos, { row = new_row, col = new_col })
				if continue ~= nil then
					break
				end
			end
			pos.row = new_row
			pos.col = new_col
			tmp[pos.row][pos.col] = "X"
		end
	end

	return tmp, has_loop
end

---Returns the amount of distinct positions the guard will visit before leaving the area
---@param map string[][]
---@param start position
---@return number
local function count_movements(map, start)
	local count = 1
	iterate(map, start, {
		callback = function(tmp, _, new_pos)
			if tmp[new_pos.row][new_pos.col] ~= "X" then
				count = count + 1
				tmp[new_pos.row][new_pos.col] = "X"
			end
		end,
	})
	return count
end

---Counts obstacle positions that cause the guard to enter a loop
---@param map string[][]
---@param start position
---@return number
local function count_possible_obstructions(map, start)
	local obstacles = {}
	iterate(map, start, {
		callback = function(tmp, _, new_pos)
			local obstruction_key = new_pos.row .. "," .. new_pos.col
			if obstacles[obstruction_key] then
				return
			end

			-- Simulate the guard's movement with new obstruction
			local modified_map = table.copy(tmp)
			modified_map[new_pos.row][new_pos.col] = "#"
			local _, has_loop = iterate(modified_map, start)
			if has_loop then
				obstacles[obstruction_key] = true
			end
		end,
	})
	local count = 0
	for _ in pairs(obstacles) do
		count = count + 1
	end
	return count
end

local map, start = parse_input(file_name)

--- Day 6: Guard Gallivant ---
print(count_movements(map, start))

--- Part Two ---
print(count_possible_obstructions(map, start))
