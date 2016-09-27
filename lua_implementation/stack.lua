local stack = {}
local meta = {}

function stack.new(size,t)
	size = size or -1
	local holderT = t or {}
	local st = {}
	function st.push(val)
		if(size > -1 and #holderT >= size) then
			return false
		else
			table.insert(holderT, val)
			return val
		end
	end
	function st.pop()
		return table.remove(holderT)
	end
	function st.peek() -- Note, peek may be more expensive than a pop operation, but less so than a pop/push
		return holderT[#holderT]
	end
	function st.len()
		return #holderT
	end
	function st.clone()
		local clone = stack.new()
		for k,v in ipairs(holderT) do
			clone.push(v)
		end
		return clone
	end
	function st.hasValue(val)
		for k,v in pairs(holderT) do
			if v == val then
				return true
			end
		end
		return false
	end
	function st.inverse()
		local t = {}
		for k,v in pairs(holderT) do
			t[#holderT-(k-1)] = v
		end
		return t
	end
	function st.invert()
		holderT = st.inverse()
		return st
	end
	return st
end

return stack