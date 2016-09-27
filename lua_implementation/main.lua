stack=require'stack'

math.randomseed(os.time())

reg = stack.new()
loops = stack.new()
mem = {}

input = io.open(arg[1]):read('*a')
for k,v in ipairs(arg) do
	if k > 1 then
		reg.push(v)
	end
end
def_funcs = {}
def_funcs['+'] = function()
	local a, b = reg.pop(), reg.pop()
	if not tonumber(a) or not tonumber(b) then
		reg.push(b..a)
	else
		reg.push(a+b)
	end
end

function findEnd(str)
	local a, b = str:find('end'), str:find('#')
	if b and b < a then
		local A = b+1+findEnd(str:sub(b+1))
		return A+findEnd(str:sub(A))
	else
		return a
	end
end

function findElse(str)
	local a, b = math.min(str:find('else')or#str,str:find('end')or#str), str:find('#')
	if b and b < a then
		local A = b+1+findEnd(str:sub(b+1))
		return A+findElse(str:sub(A))
	else
		return a
	end
end

def_funcs['-'] = function() local a,b = reg.pop(),reg.pop() reg.push(b-a) end
def_funcs['*'] = function() local a,b = reg.pop(),reg.pop() reg.push(b*a) end
def_funcs['/'] = function() local a,b = reg.pop(),reg.pop() reg.push(b/a) end
def_funcs['//'] = function() local a,b = reg.pop(),reg.pop() reg.push(math.floor(b/a)) end
def_funcs['^'] = function() local a,b = reg.pop(),reg.pop() reg.push(b^a) end
def_funcs[']'] = function() reg.push(reg.peek()) end
def_funcs['['] = function() reg.pop() end
def_funcs['\\'] = function() local a,b = reg.pop(), reg.pop() reg.push(a) reg.push(b) end
def_funcs['=='] = function() local a,b = reg.pop(),reg.pop() reg.push(b == a) end
def_funcs['!='] = function() local a,b = reg.pop(),reg.pop() reg.push(b ~= a) end
def_funcs['>='] = function() local a,b = reg.pop(),reg.pop() reg.push(b >= a) end
def_funcs['<='] = function() local a,b = reg.pop(),reg.pop() reg.push(b <= a) end
def_funcs['>'] = function() local a,b = reg.pop(),reg.pop() reg.push(b > a) end
def_funcs['<'] = function() local a,b = reg.pop(),reg.pop() reg.push(b < a) end
def_funcs['getraw'] = function(_,_,funcs) reg.push(funcs[reg.pop()]) end
def_funcs['Q'] = function(i,inp) reg.push(inp) end
def_funcs['asoc'] = function() local a = reg.pop() if type(a)=='table' then a[reg.pop()] = reg.pop() else mem[a] = reg.pop() end end
def_funcs['recall'] = function() reg.push(mem[reg.pop()]) end
def_funcs['char'] = function() reg.push(string.char(reg.pop())) end
def_funcs['byte'] = function() reg.push(string.byte(reg.pop())) end
def_funcs['%'] = function() local a,b = reg.pop(),reg.pop() reg.push(b % a) end
def_funcs['max'] = function() reg.push(math.max(reg.pop(),reg.pop())) end
def_funcs['min'] = function() reg.push(math.min(reg.pop(),reg.pop())) end
def_funcs['p'] = function() print(reg.pop()) end
def_funcs['rand'] = function()local b = reg.pop()if(type(b)=='table')then local i = math.random(b.len())local s = b.clone()local o = nil for z=1, i do o = s.pop()end reg.push(o)else local a = reg.pop() reg.push(math.random()*(b-a)+a) end end
def_funcs['randomseed'] = function() math.randomseed(reg.pop()) end
def_funcs['time'] = function() reg.push(os.time()) end
def_funcs['len'] = function() local a = reg.pop() if (type(a)=='string') then reg.push(#a) else reg.push(a.len()) end end
def_funcs['floor'] = function() reg.push(math.floor(reg.pop())) end
def_funcs['sub'] = function() local a,b,c = reg.pop(),reg.pop(),reg.pop() reg.push(c:sub(b,a)) end
def_funcs['do'] = function(_,_,l) rpn(reg.pop(),false,l) end
def_funcs['stack'] = function() reg.push(stack.new()) end
def_funcs['reg'] = function() reg.push(reg) end
def_funcs['push'] = function() local a,b = reg.pop(),reg.pop() b.push(a) end
def_funcs['pop'] = function() reg.push(reg.pop().pop()) end
def_funcs['peek'] = function() reg.push(reg.pop().peek()) end
def_funcs['mem'] = function() reg.push(mem) end
def_funcs['flow'] = function() reg.push(flow) end
def_funcs['local'] = function(i,inp,f,l) reg.push(l) end
def_funcs['read'] = function() reg.push(io.read()) end
def_funcs['find'] = function() local a,b = reg.pop(),reg.pop() reg.push(b:find(a)) end
def_funcs['rep'] = function() local a,b = reg.pop(),reg.pop() reg.push(b:rep(a)) end
def_funcs['replace'] = function() local a,b,c = reg.pop(),reg.pop(),reg.pop() reg.push(c:gsub(b,a)) end
def_funcs['frombase'] = function()
	local a,b = reg.pop(),reg.pop()
	local n = 0
	if(type(b)=='string')then
		while #b > 0 do
			local s = b:sub(1,1)
			b = b:sub(2,#b)
			s = s:byte()
			if s >= 48 and s <= 57 then
				s = string.char(s)
			else
				s = s - 55
			end
			n = n * a + s
		end
	end
	reg.push(math.floor(n))
end
def_funcs['base'] = function()
	local a = reg.pop()
	local b = reg.pop()
	if(type(b)=='number')then
		local s = ''
		while b > 0 do
			local n = (b % a)
			if n >= 10 then
				n = string.char(55 + n)
			end
			s = n .. s
			b = math.floor(b / a)
		end
		reg.push(s)
	end
end
def_funcs['sum'] = function(_,_,f)
	local a = reg.pop()
	if(type(a)=='table')then
		local val = a.pop()
		local val2 = a.pop()
		while val2 do
			reg.push(val)
			reg.push(val2)
			f['+']()
			val = reg.pop()
			val2 = a.pop()
		end
		reg.push(val)
	else
		reg.push(a)
		f['+']()
	end
end
def_funcs['type'] = function()
	local v = reg.pop()
	local t = type(v)
	if t == "string" then
		reg.push(t)
	elseif t == "table" then
		if v.push then
			reg.push("stack")
		else
			reg.push("array")
		end
	else
		reg.push("function")
	end
end
def_funcs['tostack'] = function(_,_,f)
	reg.push('.')
	f['split']()
end
def_funcs['split'] = function()
	local b, a = reg.pop(), reg.pop()
	local s = stack.new()
	for str in a:gmatch(b) do
		s.push(str)
	end
	reg.push(s)
end
def_funcs['inverse'] = function()
	reg.push(stack.new(-1,reg.pop().inverse()))
end
def_funcs['invert'] = function()
	reg.push(reg.pop().invert())
end
def_funcs['get'] = function()
	local a, b = reg.pop(), reg.pop()
	reg.push(b[a])
end
def_funcs['set'] = function()
	local a, b, c = reg.pop(),reg.pop(),reg.pop()
	c[b] = a
end
def_funcs['truthy'] = function()
	local case = reg.pop()
	if(type(case)=='number')then
		case = case ~= 0
	elseif type(case)=='string' then
		case = #case > 0
	else
		case = not not case
	end
	reg.push(case)
end
function flow_to(i,inp,funcs)
	local t = {}
	local inStr = false
	local d = 0
	local qUsed = ''
	local s = inp:sub(i)
	for k,v,K in s:gmatch('()(%S+)()') do
		local k,K = k+i,K+i
		if not inStr then
			if(funcs[v] == def_funcs['end'] or (funcs[v] == def_funcs['else'] and d==0))then
				d = d - 1
				if d < 0 then
					t.i = K-1
					return t
				end
			elseif(flow.hasValue(funcs[v]))then
				d = d + 1
			else
				for k2,v2 in v:gmatch('()(.)') do
					if not inStr then
						if v2 == '"' or v2 == "'" then
							qUsed = v2
							inStr = true
						end
					else
						if v2 == qUsed then
							inStr = false
						end
					end
				end
			end
		else
			for k2,v2 in v:gmatch('()(.)') do
				if not inStr then
					if v2 == '"' or v2 == "'" then
						qUsed = v2
						inStr = true
					end
				else
					if v2 == qUsed then
						inStr = false
					end
				end
			end
		end
	end
end
def_funcs['if'] = function(i,inp,funcs)
	funcs['truthy'](i,inp) local case = reg.pop()
	loops.push('if')
	local t = {i = i}
	if not case then
		local s = stack.new()
		return {i = flow_to(i,inp,funcs).i - 4}
	end
	return t
end
def_funcs['if_peek'] = function(i,inp,funcs)
	reg.push(reg.peek())
	funcs['truthy'](i,inp) local case = reg.pop()
	loops.push('if')
	local t = {i = i}
	if not case then
		local s = stack.new()
		return {i = flow_to(i,inp,funcs).i - 4}
	end
	return t
end

def_funcs['for'] = function(i, inp, l)
	-- a: The loop counter
	-- b: The maximum / minimum
	-- c: The increment/decrement value
	-- d: holder to confirm that this is a for loop.
	local a,b,c,d = loops.pop(),loops.pop(),loops.pop(),loops.pop()
	if d~="FORLOOPHOLDER" then -- There is no standard way that anything but for loops can do this (Unless redefining loops externally)
		-- Put everything back were we found it. Pushing nil's to the bottom of the stack is fine to do, so if we do a for loop as the very first thing, it's allllll good.
		loops.push(d)
		loops.push(c)
		loops.push(b)
		loops.push(a)
		d = "FORLOOPHOLDER"
		a,b,c = reg.pop(),reg.pop(),reg.pop()
		a = a - c -- We do this to counteract what we will do next. (a = a + c)
	end
	a = a + c
	if c > 0 and a > b or c < 0 and a < b then
		-- Loop finished, terminate.
		i = flow_to(i,inp,l).i
		return {i = i}
	else
		-- Store all that juicy self provided data.
		loops.push(d)
		loops.push(c)
		loops.push(b)
		loops.push(a)
		loops.push(i - (#'for'+1))
		reg.push(a) -- and give access to a.
	end
end
def_funcs['function'] = function(i,inp,l)
	local n = flow_to(i,inp,l).i
	local f = function()
		rpn(inp:sub(i+1,n-4),false,l)
	end
	reg.push(f)
	return {i = n}
end
def_funcs['end'] = function(i,inp)
	local v = loops.pop()
	if(tonumber(v))then
		local t = {i = v}
		return t
	end
end
def_funcs['while'] = function(i, inp, funcs)
	funcs['truthy'](i,inp) local case = reg.pop()
	if case then
		loops.push(i - (#'while'+1))
	else
		local t = flow_to(i,inp,funcs)
		return t
	end
end
def_funcs['while_peek'] = function(i, inp, funcs)
	reg.push(reg.peek())
	funcs['truthy'](i,inp) local case = reg.pop()
	if case then
		loops.push(i - (#'while'+1))
	else
		local t = flow_to(i,inp,funcs)
		return t
	end
end
def_funcs['else'] = function(i,inp,funcs)
	local t = {i = flow_to(i,inp,funcs).i}
	loops.pop()
	return t
end
def_funcs['debug'] = function(i,inp)
	local newStack = reg.clone()
	local str = ""
	while newStack.len() > 0 do
		str = str .. "\""..tostring(newStack.pop()).."\"" .. ", "
	end
	print(str)
end

flow = stack.new()
flow.push(def_funcs['if'])
flow.push(def_funcs['if_peek'])
flow.push(def_funcs['for'])
flow.push(def_funcs['while'])
flow.push(def_funcs['while_peek'])
flow.push(def_funcs['function'])

local sugar = io.open('sugar.txt')
sugar = sugar:read('*a')
for str in sugar:gmatch"[^\r\n]*" do
	local a,b = str:match("(%S+)%s+(%S+)")
	if a and b and def_funcs[b] then
		def_funcs[a] = def_funcs[b]
	end
end

function rpn(input, doEchoStack, upperLocal)
	local locals = setmetatable({},{__index = upperLocal})
	local funcs = setmetatable({}, {__index = function(t, key)
		if(locals[key])then
			local v = locals[key]
			if(type(v)=='function')then
				return v
			else
				return function() reg.push(v) end
			end
		elseif(mem[key])then
			local v = mem[key]
			if(type(v)=='function')then
				return v
			else
				return function() reg.push(v) end
			end
		elseif tonumber(key) then
			return function() reg.push(tonumber(key)) end
		elseif key:lower()=='true' then
			return function() reg.push(true) end
		elseif key:lower()=='false' then
			return function() reg.push(false) end
		end
		return def_funcs[key]
	end})
	local inString = false
	local usedQoute = ''
	local builtWord = ''
	local varType = ''
	local function stuff(i)
		if varType == 'String' then
			reg.push(builtWord)
		else
			local f = funcs[builtWord]
			if f then
				local b,t = pcall(f, i, input, funcs, locals)
				if not b then
					local _,n = input:sub(0,i):gsub('%w+','')
					print(("-"):rep(20))
					print("MEMORY DUMP")
					print(("-"):rep(20))
					while reg.len()>0 do
						print(reg.pop())
					end
					print(("-"):rep(20))
					error("ERROR: \""..t.."\" AT WORD "..n+1 ..", '"..builtWord.."'")
				elseif t then
					i = t.i or i
				end
			end
		end
		varType = ''
		builtWord = ''
		return i
	end
	local i = 1
	while i <= #input do
		local s = input:sub(i,i)
		if s == '"' or s == "'" then
			if (s==usedQoute or not inString) then
				usedQoute = s
				inString = not inString
				varType = 'String'
			else
				builtWord = builtWord..s
			end
		elseif not inString and s:find("%s") then
			local oli = i
			i = stuff(i)
		else
			builtWord = builtWord .. s
		end
		i = i + 1
	end
	stuff(#input)
	if doEchoStack then
		local val = reg.pop()
		while val~=nil do
			print(val)
			val = reg.pop()
		end
	end
end

rpn(input, true)