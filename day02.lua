---@type boolean
local DEBUG = false
---@type string
local file_name = DEBUG and "./example.txt" or "./input.txt"

---@enum trend
local TREND = {
	increasing = 1,
	decreasing = 2,
	equal = 3,
}

---@param n1 number
---@param n2 number
---@return trend
local function get_trend(n1, n2)
	if n1 < n2 then
		return TREND.increasing
	elseif n1 > n2 then
		return TREND.decreasing
	else
		return TREND.equal
	end
end

---@param file_path string
---@return number[][] reports
local function parse_input(file_path)
	---@type number[][]
	local reports = {}
	for line in io.lines(file_path) do
		---@type number[]
		local report = {}
		for level in line:gmatch("%d+") do
			table.insert(report, tonumber(level))
		end
		table.insert(reports, report)
	end
	return reports
end

---@param levels number[]
---@return boolean
local function validate_levels(levels)
	if #levels < 2 then
		return false
	end
	---@type trend
	local trend = nil
	for i = 2, #levels do
		local diff = levels[i] - levels[i - 1]
		local current_trend = get_trend(levels[i - 1], levels[i])
		if math.abs(diff) < 1 or math.abs(diff) > 3 or current_trend == TREND.equal then
			return false
		end
		-- First iteration
		if trend == nil then
			trend = current_trend
		elseif current_trend ~= trend then
			return false
		end
	end
	return true
end

---@param levels number[]
---@param tolerance? number
---@return boolean
local function is_safe_report(levels, tolerance)
	tolerance = tolerance or 0

	if validate_levels(levels) then
		return true
	end

	if tolerance > 0 then
		for i = 1, #levels do
			---@type number[]
			local adjusted_levels = {}
			for j = 1, #levels do
				-- Remove current level and try again
				if j ~= i then
					table.insert(adjusted_levels, levels[j])
				end
			end
			if validate_levels(adjusted_levels) then
				return true
			end
		end
	end
	return false
end

---@param reports number[][]
---@param tolerance? number
---@return number
local function count_safe_reports(reports, tolerance)
	local total = 0
	for _, report in ipairs(reports) do
		if is_safe_report(report, tolerance) then
			total = total + 1
		end
	end
	return total
end

local reports = parse_input(file_name)

--- Day 2: Red-Nosed Reports ---
print(count_safe_reports(reports))

--- Part Two ---
print(count_safe_reports(reports, 1))
