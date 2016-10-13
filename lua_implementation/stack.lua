local stack = {}
local meta = {}

local unpack = unpack or table.unpack -- WHO DID THIS, WHO MADE UNPACK NON-GLOBAL RANDOMLY?

function stack.new(size,t)
	size = size or -1
	local holderT = t or {}
	local st = {}
	function st.push(...)
		local a = {...}
		for k,val in pairs(a) do
			if(size > -1 and #holderT >= size) then
				return false
			else
				table.insert(holderT, val)
				return val
			end
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
		local clone = stack.new(size)
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
	function st.shuffle()
		local nST = st.clone()
		local s = st.len()
		holderT = {}
		while nST.len()>0 do
			local n = math.random(1,#holderT+1)
			table.insert(holderT, n, nST.pop())
		end
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
	function st.replace_all(n)
		for k,v in ipairs(holderT) do
			if(type(n)=="function")then
				holderT[k] = n(v)
			end
			-- More types in future?
		end
	end

	function st.apply(f) -- IT WAS JAVASCRIPT'S IDEA IS SWEAR!
		return f(unpack(holderT))
	end
	st.size = size
	return st
end

return stack