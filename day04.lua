local DEBUG = false
local file_name = DEBUG and "./example.txt" or "./input.txt"

---@type table<string, [number, number]>
local DIRECTIONS = {
	topleft = { -1, -1 },
	top = { -1, 0 },
	topright = { -1, 1 },
	left = { 0, -1 },
	right = { 0, 1 },
	bottomleft = { 1, -1 },
	bottom = { 1, 0 },
	bottomright = { 1, 1 },
}

---@param file_path string
---@return string[][]
local function parse_input(file_path)
	---@type string[][]
	local puzzle = {}
	for line in io.lines(file_path) do
		local row = {}
		for c in line:gmatch(".") do
			table.insert(row, c)
		end
		table.insert(puzzle, row)
	end
	return puzzle
end

---Traverses the grid in a specific direction to match the search string
---@param grid string[][]
---@param search string
---@param start_pos [number, number]
---@param direction [number, number]
---@return boolean --Whether the string was found
local function traverse(grid, search, start_pos, direction)
	local new_row = start_pos[1]
	local new_col = start_pos[2]
	for i = 1, #search do
		if new_row < 1 or new_col < 1 or new_row > #grid or new_col > #grid[1] then
			return false
		end
		if grid[new_row][new_col] ~= search:sub(i, i) then
			return false
		end
		new_row = new_row + direction[1]
		new_col = new_col + direction[2]
	end
	return true
end

---Counts `all` occurrences of the word inside a grid
---@param puzzle string[][]
---@param word string
---@return number
local function count_word_occurrences(puzzle, word)
	local count = 0
	local first_char = word:sub(1, 1)
	for i, row in ipairs(puzzle) do
		for j, col in ipairs(row) do
			if col == first_char then
				for _, direction in pairs(DIRECTIONS) do
					if traverse(puzzle, word, { i, j }, direction) then
						count = count + 1
					end
				end
			end
		end
	end
	return count
end

---Counts `X`-shaped patterns made of the word in diagonal directions
---@param puzzle string[][]
---@param word string
---@return number
local function count_diagonal_crosses(puzzle, word)
	assert(#word % 2 ~= 0, "Invalid size, search string must have an odd length.")
	local count = 0
	local middle_char = word:sub(math.ceil(#word / 2), math.ceil(#word / 2))
	local diagonal_directions = {
		DIRECTIONS.topleft,
		DIRECTIONS.topright,
		DIRECTIONS.bottomleft,
		DIRECTIONS.bottomright,
	}
	for i, row in ipairs(puzzle) do
		for j, col in ipairs(row) do
			if col == middle_char then
				local found = 0
				for _, direction in pairs(diagonal_directions) do
					-- Start traversal from the origin of the search word
					local start_row = i - (direction[1] * math.floor(#word / 2))
					local start_col = j - (direction[2] * math.floor(#word / 2))
					if traverse(puzzle, word, { start_row, start_col }, direction) then
						found = found + 1
					end
				end
				if found >= 2 then
					count = count + 1
				end
			end
		end
	end
	return count
end

local puzzle = parse_input(file_name)

--- Day 4: Ceres Search ---
print(count_word_occurrences(puzzle, "XMAS"))

--- Part Two ---
print(count_diagonal_crosses(puzzle, "MAS"))
