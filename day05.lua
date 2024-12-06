local DEBUG = false
local file_name = DEBUG and "./example.txt" or "./input.txt"

---@param file_path string
---@return number[][]
---@return number[][]
local function parse_input(file_path)
	local ordering_rules = {}
	local updates = {}
	for line in io.lines(file_path) do
		local n1, n2 = line:match("(%d+)|(%d+)")
		if n1 then
			table.insert(ordering_rules, { tonumber(n1), tonumber(n2) })
		else
			if line ~= "" then
				local pages = {}
				for num in line:gmatch("%d+") do
					table.insert(pages, tonumber(num))
				end
				table.insert(updates, pages)
			end
		end
	end
	return ordering_rules, updates
end

---Checks whether the page order aligns with the rules
---@param pages number[]
---@param rules number[][]
---@return boolean --True if the order is valid, false otherwise
---@return table? --Violated rules (if any)
local function is_valid(pages, rules)
	local violations = {}
	for _, rule in ipairs(rules) do
		local idx1, idx2 = nil, nil
		for i, num in ipairs(pages) do
			if num == rule[1] then
				idx1 = i
			elseif num == rule[2] then
				idx2 = i
			end
			if idx1 and idx2 then
				break
			end
		end
		if idx1 and idx2 and idx1 > idx2 then
			table.insert(violations, rule)
		end
	end
	return #violations == 0, violations
end

---Corrects the page order based on the given rules
---@param pages number[]
---@param rules number[][]
---@return number[]
local function reorder(pages, rules)
	local corrected_pages = { table.unpack(pages) }
	local changed = true
	while changed do
		changed = false
		local valid, violations = is_valid(corrected_pages, rules)
		if not valid and violations then
			for _, rule in ipairs(violations) do
				local idx1, idx2 = nil, nil
				for i, num in ipairs(corrected_pages) do
					if num == rule[1] then
						idx1 = i
					elseif num == rule[2] then
						idx2 = i
					end
					if idx1 and idx2 then
						break
					end
				end
				-- Ensure proper page placement
				if idx1 and idx2 and idx1 > idx2 then
					table.remove(corrected_pages, idx1)
					table.insert(corrected_pages, idx2, rule[1])
					changed = true
					break
				end
			end
		end
	end
	return corrected_pages
end

---Separates updates into valid and invalid
---@param rules number[][]
---@param updates number[][]
---@return number[][] valid
---@return number[][] invalid
local function split_updates(rules, updates)
	local valid, invalid = {}, {}
	for _, pages in ipairs(updates) do
		if is_valid(pages, rules) then
			table.insert(valid, pages)
		else
			table.insert(invalid, pages)
		end
	end
	return valid, invalid
end

---@param updates number[][]
---@return number
local function sum_middle_pages(updates)
	local total = 0
	for _, pages in ipairs(updates) do
		total = total + pages[math.ceil(#pages / 2)]
	end
	return total
end

local ordering_rules, updates = parse_input(file_name)
local valid_updates, invalid_updates = split_updates(ordering_rules, updates)

--- Day 5: Print Queue ---
print(sum_middle_pages(valid_updates))

--- Part Two ---
local corrected_updates = {}
for _, pages in ipairs(invalid_updates) do
	table.insert(corrected_updates, reorder(pages, ordering_rules))
end

print(sum_middle_pages(corrected_updates))
