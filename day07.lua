local DEBUG = false
local file_name = DEBUG and "./example.txt" or "./input.txt"

---@param file_path string
---@return { [number]: number[] }
local function parse_input(file_path)
	local equations = {}
	for line in io.lines(file_path) do
		local test_value, nums = line:match("(%d+):%s*(.*)")
		if test_value and nums then
			local tmp = {}
			for n in nums:gmatch("(%d+)") do
				table.insert(tmp, tonumber(n))
			end
			equations[tonumber(test_value)] = tmp
		end
	end
	return equations
end

---Checks whether `nums` can produce `test_value` using `+` and `*`
---@param test_value number
---@param nums { [number]: number[] }
---@param idx number
---@param current number
---@return boolean
local function is_solvable(test_value, nums, idx, current)
	if idx > #nums then
		return current == test_value
	end
	local next_num = nums[idx]
	if is_solvable(test_value, nums, idx + 1, current + next_num) then
		return true
	end
	if is_solvable(test_value, nums, idx + 1, current * next_num) then
		return true
	end
	return false
end

---Checks whether `nums` can produce `test_value` using `+`, `*` and `||`
---@param test_value number
---@param nums { [number]: number[] }
---@param idx number
---@param current number
---@return boolean
local function is_solvable_p2(test_value, nums, idx, current)
	if idx > #nums then
		return current == test_value
	end
	local next_num = nums[idx]
	if is_solvable_p2(test_value, nums, idx + 1, current + next_num) then
		return true
	end
	if is_solvable_p2(test_value, nums, idx + 1, current * next_num) then
		return true
	end
	local combined = tonumber(current .. next_num) --[[@as number]]
	if is_solvable_p2(test_value, nums, idx + 1, combined) then
		return true
	end
	return false
end

---@param equations { [number]: number[] }
---@param concat? boolean
---@return number
local function count_solvable_equations(equations, concat)
	---@type function
	local func = is_solvable
	if concat ~= nil then
		func = is_solvable_p2
	end
	local total = 0
	for test_value, nums in pairs(equations) do
		if func(test_value, nums, 2, nums[1]) then
			total = total + test_value
		end
	end
	return total
end

local equations = parse_input(file_name)

--- Day 7: Bridge Repair ---
print(count_solvable_equations(equations))

--- Part Two ---
local sum = count_solvable_equations(equations, true)
print(string.format("%.0f", sum))
