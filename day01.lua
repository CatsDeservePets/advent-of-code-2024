---@type boolean
local DEBUG = false
---@type string
local file_name = DEBUG and "./example.txt" or "./input.txt"

---@param file_path string
---@return number[] left
---@return number[] right
local function parse_input(file_path)
	local left, right = {}, {}
	for line in io.lines(file_path) do
		local n1, n2 = line:match("(%d+)%s+(%d+)")
		table.insert(left, tonumber(n1))
		table.insert(right, tonumber(n2))
	end
	table.sort(left)
	table.sort(right)
	return left, right
end

---@param left number[]
---@param right number[]
---@return number[]
local function calculate_distances(left, right)
	assert(
		#left == #right,
		string.format("List size mismatch: Expected equal lengths but got %d and %d", #left, #right)
	)
	---@type number[]
	local distances = {}
	for i = 1, #left do
		table.insert(distances, math.abs(left[i] - right[i]))
	end
	return distances
end

---@param left number[]
---@param right number[]
---@return number[]
local function calculate_similarities(left, right)
	---@type number[]
	local similarity_score = {}
	for _, n1 in ipairs(left) do
		local matches = 0
		for _, n2 in ipairs(right) do
			if n1 == n2 then
				matches = matches + 1
			end
		end
		table.insert(similarity_score, n1 * matches)
	end
	return similarity_score
end

---@param numbers number[]
---@return number
local function sum(numbers)
	local total = 0
	for _, n in ipairs(numbers) do
		total = total + n
	end
	return total
end

local left, right = parse_input(file_name)

--- Day 1: Historian Hysteria ---
local distances = calculate_distances(left, right)
print(sum(distances))

--- Part Two ---
local similarities = calculate_similarities(left, right)
print(sum(similarities))
