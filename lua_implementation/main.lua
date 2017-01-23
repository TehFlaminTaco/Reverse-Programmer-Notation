if arg[0] then
	function require(lib)
		local dir = arg[0]:gsub("main.lua$","")
		return loadfile(dir..lib)()
	end
end

stack=require'stack'

math.randomseed(os.time())

reg = stack.new()
loops = stack.new()
mem = {}

-- TRY INPUT
input = io.open(arg[1]):read('*a')
-- END TRY INPUT

for k,v in ipairs(arg) do
	if k > 1 then
		if v:match("^{.*}$") then
			local s = stack.new()
			local inString = false
			local val = ''
			for S in v:gsub("^{",""):gsub("}$",""):gmatch(".") do
				if S == "'" then
					inString = not inString
				else
					if inString or S~=","then
						val = val .. S
					elseif S == "," then
						s.push(val)
						val = ""
					end
				end
			end
			if val then
				s.push(val)
			end
			s.invert()
			reg.push(s)
		else
			reg.push(v)
		end
	end
end

local stringmeta = getmetatable("")
local funcmeta = {}
debug.setmetatable(function()end, funcmeta)

function stringmeta.__mul(a,b)
	if(type(a)=='string')then return a:rep(b) end
	if(type(b)=='string')then return b:rep(a) end
end

function funcmeta.__mul(a,b)
	if(type(a)=='function')then return function(...) for i=1,b do a(...) end end end
	if(type(b)=='function')then return function(...) for i=1,a do b(...) end end end
end

function funcmeta.__concat(a,b)
	return function(...) a(...) b(...) end
end

def_funcs = {}

function wrapFunc(func,n)
	local n = n or 1
	return function()
		local vals = stack.new()
		for i=1, n do
			vals.push(reg.pop())
		end
		reg.push(vals.apply(func))
	end
end

def_funcs['+'] = function(...)
	local a, b = reg.pop(), reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(b)=='boolean' then
		b = b and 1 or 0
	end
	
	if(type(b)=="table")then
		b.replace_all(function(x) return x + a end)
		reg.push(b)
	elseif(type(a)=='table')then
		reg.push(b) reg.push(a)
		def_funcs['sum'](...) -- Just sum the bastard instead of trying to add it to something.
	else
		if not tonumber(a) or not tonumber(b) then
			reg.push(b..a)
		else
			reg.push(a+b)
		end
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

def_funcs['.'] = function(_,_,f) 
	local a = reg.pop()
	if(type(a)=='table')then
		local a = stack.new(-1,a.inverse()) -- See below regarding use of inverse.
		reg.push(table.concat(a.apply(table.pack)))
	else
		local b = reg.pop()
		if type(b)=='table' then
			local b = stack.new(-1,b.inverse()) -- Using inverse instead of clone to maintain old functionality.
			reg.push(table.concat(b.apply(table.pack),a))
		else
			reg.push(tostring(b)..tostring(a))
		end
	end
end
def_funcs['x'] = function() reg.push('x') end
def_funcs['y'] = function() reg.push('y') end
def_funcs['z'] = function() reg.push('z') end
def_funcs['X'] = function() reg.push('X') end
def_funcs['Y'] = function() reg.push('Y') end
def_funcs['Z'] = function() reg.push('Z') end
local tempRegStacks = stack.new();
def_funcs['('] = function()
	tempRegStacks.push(reg);
	reg = stack.new();
end
def_funcs[')'] = function()
	local r = tempRegStacks.pop();
	r.push(reg);
	reg = r;
end
def_funcs['-'] = function()
	local a,b = reg.pop(),reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(b)=='boolean' then
		b = b and 1 or 0
	end
	if(type(b)=='table' and type(a)=='table')then
		local a = a.clone()
		local b = b.clone()
		local s = stack.new()
		while math.min(a.len(), b.len())>0 do
			local A,B = a.pop(), b.pop()
			s.push(A-B)
		end
		reg.push(s)
		return
	end
	if type(b)=='table' then
		local b = b.clone()
		b.replace_all(function(z) return z-a end)
		reg.push(b)
	elseif type(a)=='table' then
		local a = a.clone()
		a.replace_all(function(z) return b-z end)
		reg.push(a)
	else
		reg.push(b-a)
	end
end
def_funcs['*'] = function()
	local a,b = reg.pop(),reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(b)=='boolean' then
		b = b and 1 or 0
	end
	if type(a)=='table' then
		reg.push(b)
		local a = a.clone()
		local n = 1
		while a.len()>0 do
			local z = a.pop()
			if type(z)=='boolean' then
				z = z and 1 or 0
			end
			n = n * z
		end
		reg.push(n)
	elseif(type(b)=='table')then
		local b = b.clone()
		b.replace_all(function(z) return z*a end)
		reg.push(b)
	else
		reg.push(b*a)
	end
end
def_funcs['/'] = function()
	local a,b = reg.pop(),reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(b)=='boolean' then
		b = b and 1 or 0
	end
	if type(b)=='table' then
		local b = b.clone()
		b.replace_all(function(z) return z/a end)
		reg.push(b)
	elseif type(a)=='table' then
		local a = a.clone()
		a.replace_all(function(z) return b/z end)
		reg.push(a)
	else
		reg.push(b/a)
	end
end
def_funcs['//'] = function()
	local a,b = reg.pop(),reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(b)=='boolean' then
		b = b and 1 or 0
	end
	if type(b)=='table' then
		local b = b.clone()
		b.replace_all(function(z) return math.floor(z/a) end)
		reg.push(b)
	elseif type(a)=='table' then
		local a = a.clone()
		a.replace_all(function(z) return math.floor(b/z) end)
		reg.push(a)
	else
		reg.push(math.floor(b/a))
	end
end
def_funcs['^'] = function()
	local a,b = reg.pop(),reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(b)=='boolean' then
		b = b and 1 or 0
	end
	if type(b)=='table' then
		local b = b.clone()
		b.replace_all(function(z) return z^a end)
		reg.push(b)
	elseif type(a)=='table' then
		local b = b.clone()
		a.replace_all(function(z) return b^z end)
		reg.push(a)
	else
		reg.push(b^a)
	end
end
def_funcs['sqrt'] = function()
	local a = reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(a)=='table' then
		local b = b.clone()
		a.replace_all(function(z) return math.sqrt(z) end)
		reg.push(a)
	else
		reg.push(math.sqrt(a))
	end
end
def_funcs['t'] = function() reg.push(10) end
def_funcs[']'] = function() reg.push(reg.peek()) end
def_funcs['['] = function() reg.pop() end
def_funcs['\\'] = function() local a,b = reg.pop(), reg.pop() reg.push(a) reg.push(b) end
def_funcs['=='] = function() local a,b = reg.pop(),reg.pop() reg.push(b == a) end
def_funcs['!='] = function() local a,b = reg.pop(),reg.pop() reg.push(b ~= a) end
def_funcs['>='] = function() local a,b = reg.pop(),reg.pop() reg.push(b >= a) end
def_funcs['<='] = function() local a,b = reg.pop(),reg.pop() reg.push(b <= a) end
def_funcs['>'] = function() local a,b = reg.pop(),reg.pop() reg.push(b > a) end
def_funcs['<'] = function() local a,b = reg.pop(),reg.pop() reg.push(b < a) end
def_funcs['to'] = function()
	local a, b = reg.pop(),reg.pop()
	local o = stack.new()
	if type(a) == 'number' then
		for i=b, a, a > b and 1 or -1 do
			o.push(i)
		end
	else
		for i=b:byte(), a:byte(), a:byte() > b:byte() and 1 or -1 do
			o.push(string.char(i))
		end
	end
	reg.push(o)

end
def_funcs['getraw'] = function(_,_,funcs) reg.push(funcs[reg.pop()]) end
def_funcs['shuffle'] = function() reg.peek().shuffle() end
def_funcs['clone'] = function() reg.push(reg.peek().clone()) end
def_funcs['Q'] = function(i,inp) reg.push(inp) end
def_funcs['asoc'] = function() local a = reg.pop() if type(a)=='table' then a[tostring(reg.pop())] = reg.pop() else mem[tostring(a)] = reg.pop() end end
def_funcs['recall'] = function() reg.push(mem[reg.pop()]) end
def_funcs['char'] = function()
	local a = reg.pop()
	if(type(a)=='table')then
		a.replace_all(string.char)
		reg.push(a)
	else
		reg.push(string.char(a))
	end
end
def_funcs['byte'] = function()
	local a = reg.pop()
	if(type(a)=='table')then
		a.replace_all(string.byte)
		reg.push(a)
	elseif #a > 1 then
		local o = stack.new()
		for i=1, #a do
			o.push(string.byte(a:sub(i,i)))
		end
		reg.push(o)
	else
		reg.push(string.byte(a))
	end
end
def_funcs['%'] = function()
	local a,b = reg.pop(),reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(b)=='boolean' then
		b = b and 1 or 0
	end
	if type(b)=='table' then
		b.replace_all(function(z) return z % a end)
		reg.push(b)
	elseif type(a)=='table' then
		a.replace_all(function(z) return b % z end)
		reg.push(b)
	else
		reg.push(b % a)
	end
end
def_funcs['max'] = function()
	local a = reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(b)=='boolean' then
		b = b and 1 or 0
	end
	if(type(a)=='table')then
		reg.push(a.apply(math.max))
	else
		reg.push(math.max(a,reg.pop()))
	end
end
def_funcs['min'] = function()
	local a = reg.pop()
	if type(a)=='boolean' then
		a = a and 1 or 0
	end
	if type(b)=='boolean' then
		b = b and 1 or 0
	end
	if(type(a)=='table')then
		reg.push(a.apply(math.min))
	else
		reg.push(math.min(a,reg.pop()))
	end
end
def_funcs['p'] = function() print(reg.pop()) end
def_funcs['w'] = function() io.write(reg.pop()) end
def_funcs['rand'] = function()local b = reg.pop()if(type(b)=='table')then local i = math.random(b.len())local s = b.clone()local o = nil for z=1, i do o = s.pop()end reg.push(o)else local a = reg.pop() reg.push(math.random()*(b-a)+a) end end
def_funcs['randomseed'] = function() math.randomseed(reg.pop()) end
def_funcs['time'] = function() reg.push(os.time()) end
def_funcs['len'] = function() local a = reg.pop() if (type(a)=='string') then reg.push(#a) else reg.push(a.len()) end end
def_funcs['floor'] = function()
	local a = reg.pop()
	if(type(a)=='table')then
		a.replace_all(function(z)return math.floor(z)end)
		reg.push(a)
	else
		reg.push(math.floor(a))
	end
end
def_funcs['ceil'] = function()
	local a = reg.pop()
	if(type(a)=='table')then
		a.replace_all(function(z)return math.ceil(z)end)
		reg.push(a)
	else
		reg.push(math.ceil(a))
	end
end
def_funcs['sub'] = function() local a,b,c = reg.pop(),reg.pop(),reg.pop() reg.push(c:sub(b,a)) end
def_funcs['do'] = function(x,y,z,w,r) local a = reg.pop() if type(a)=='string' then rpn(a,false,z) else a(x,y,z,w,r) end end
def_funcs['call'] = function(A,B,funcs,...) local a = reg.pop() if type(a)=='function' then a() else reg.push(a) def_funcs['do'](A,B,funcs,...) end end
def_funcs['stack'] = function() reg.push(stack.new()) end
def_funcs['not'] = function(_,_,f) f['truthy']() reg.push(not reg.pop()) end
def_funcs['reg'] = function() reg.push(reg) end
def_funcs['push'] = function() local a,b = reg.pop(),reg.pop() b.push(a)reg.push(b)end
def_funcs['pop'] = function() local a = reg.peek()reg.push(a.pop())end
def_funcs['peek'] = function() reg.push(reg.pop().peek()) end
def_funcs['hasvalue'] = function() local a,b = reg.pop(),reg.pop() reg.push(b.hasValue(a)) end
def_funcs['delta'] = function()
	local a = reg.pop()
	if(type(a))=='string'then
		a = stack.new(-1,a)
		a.replace_all(string.byte)
	end
	if type(a)=='table' then
		local nt = stack.new(a.size~=-1 and a.size-1) -- Pushes nil if a's size is negative 1, aka, infinite, which will intern make the new stack infinite. Otherwise, one slice smaller.
		local a = a.clone()							  -- I still NEVER use the size. True as of 13/10/16 5:31 AEST
		local z = a.pop()							  -- Updated 25/11/16 2:39 AEST, size is still useless.
		nt.push(z) -- Add the C value to the stack... -- Updated 06/12/16 3:55 AEST, Still useless. Maybe someday.
		while a.len() > 0 do 						  -- Updated 20/12/16 5:22 AEST, how time flies. Still useless.
			local Z = a.pop()
			nt.push(Z - z) -- Does polarity of the delta REALLLLY matter to you people? Probably. POLARITY DOES MATTER AND THIS WAS WRONG!!
			z = Z
		end
		nt.invert()
		reg.push(nt)
	else -- Why are you doing this on a non-stack. Why do you hate me?
		reg.push(a - reg.pop())
	end
end
def_funcs['idelta'] = function()
	local a = reg.pop()
	local s = stack.new()
	if(type(a)=='number')then
		-- a is a our C value. Bad naming but sue me.
		local n = a
		s.push(n)
		for k,v in ipairs(reg.pop().inverse()) do
			n = n+v
			s.push(n)
		end
		reg.push(s)
	else
		local n = 0
		for k,v in ipairs(a.inverse()) do
			n = n+v
			s.push(n)
		end
		reg.push(s)
	end
end
def_funcs['exit'] = function() return {i = math.huge} end
def_funcs['mem'] = function() reg.push(mem) end
def_funcs['flow'] = function() reg.push(flow) end
def_funcs['local'] = function(i,inp,f,l) reg.push(l) end
def_funcs['read'] = function() reg.push(io.read()) end
def_funcs['find'] = function() local a,b = reg.pop(),reg.pop() reg.push(b:find(a)) end
def_funcs['format'] = function()
	local a = reg.pop()
	local c = ({a:gsub("%%[cdEefgGiouXxqs]","")})[2] -- The amount of arguments requested by the input string.
	local t = {}
	local i = 1
	while i <= c do
		local v = reg.pop()
		if(type(v)=='table') then
			for k2, v2 in ipairs(v:inverse()) do
				table.insert(t,1,v2)
				i = i + 1
				if i > c then break end
			end
			i = i - 1
		else
			table.insert(t,1,v)
		end
		i = i + 1
	end
	reg.push(a:format(table.unpack(t)))
end
def_funcs['rep'] = function()
	local a,b = reg.pop(),reg.pop()
	if(type(b)=='function')then
		for i=1, a do
			b()
		end
	else
		reg.push(b:rep(a))
	end
end
def_funcs['lower'] = function() reg.push(reg.pop():lower()) end
def_funcs['upper'] = function() reg.push(reg.pop():upper()) end
def_funcs['alphabet'] = function() reg.push('abcdefghijklmnopqrstuvwxyz') end
def_funcs['ALPHABET'] = function() reg.push('ABCDEFGHIJKLMNOPQRSTUVWXYZ') end
def_funcs['match'] = function() local a, b = reg.pop(),reg.pop() reg.push(b:match(a)) end
def_funcs['and'] = function()
	local a = reg.pop()
	local v = false
	if type(a)=='table' then
		local a = stack.new(-1,a.inverse())
		while a.len()>0 do
			local z = a.pop()
			if not z then
				reg.push(false)
				return
			else
				v = z
			end
		end
		reg.push(v)
	else
		reg.push(reg.pop() and a)
	end
end
def_funcs['or'] = function()
	local a = reg.pop()
	if type(a)=='table' then
		local a = stack.new(-1,a.inverse())
		while a.len()>0 do
			local z = a.pop()
			if z then
				reg.push(z)
				return
			end
		end
		reg.push('false')
	else
		reg.push(reg.pop() or a)
	end
end
def_funcs['-0'] = function(_,_,f)
	local str = reg.pop()
	str = str:gsub('.[\128-\191]*','%0 ')
	reg.push(str)
	f['do']()
end
def_funcs['sort'] = function()
	local a = reg.pop()
	if(type(a)=='function')then
		local b = reg.pop()
		if type(b)=='string' then
			local b = stack.new(-1,b)
			b.sort(function(A,B)reg.push(A)reg.push(B)a()return reg.pop()end)
			reg.push(table.concat(b.apply(table.pack)))
		else
			b.sort(function(A,B)reg.push(A)reg.push(B)a()return reg.pop()end)
			reg.push(b)
		end
	else
		if type(a)=='string' then
			local a = stack.new(-1,a)
			a.sort()
			reg.push(table.concat(a.apply(table.pack)))
		else
			a.sort()
			reg.push(a)
		end
	end
end
def_funcs['dups'] = function()
	local a = reg.pop()
	if(type(a)=='string')then
		local s = ""
		for S in a:gmatch'.' do
			if not s:find(S) then s = s .. S end
		end
		reg.push(s)
	else
		local s=stack.new()
		local b = {}
		a.apply(function(...)for k,v in pairs({...}) do if not b[v] then s.push(v) b[v] = true end end end)
		reg.push(s)
	end
end
def_funcs['foreach'] = function(...)
	local b, a = reg.pop(),reg.pop().clone()
	while a.len()>0 do
		reg.push(a.pop()) b(...)
	end
end
def_funcs['replace'] = function() local a,b = reg.pop(),reg.pop()
	if(type(a)=='string')then
		reg.push(reg.pop():gsub(b,a))
	else
		if(type(b)=='string')then
			reg.push(reg.pop():gsub(b,function(...) for k,v in pairs({...}) do reg.push(v) end a() return reg.pop() end))
		else
			b.replace_all(function(z) reg.push(z) a() return reg.pop() end)
			reg.push(b)
		end
	end
end
def_funcs['map'] = function(_,_,fu)
	local f = reg.pop()
	reg.push('.')
	reg.push(f)
	fu['replace']()
end
b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' -- The ='s is a padder cell. We put this in here so we can replace nulll bytes.
def_funcs['encode64'] = function()
	local s = ''
	local a = reg.pop()
	for A,B,C in a:gmatch"(.)(.?)(.?)" do -- Search for ALL tripplets.
		local a,b,c = A:byte(), (B and B:byte() or 0), (C and C:byte() or 0)
		local n = math.floor(a * (2^16) + b * (2^8) + c)
		local d = n % 64
		c = math.floor(n / 64) % 64
		b = math.floor(math.floor(n/64)/64) % 64
		a = math.floor(math.floor(math.floor(n/64)/64)/64) % 64
		if B:len()<=0 then
			c = 64
		end
		if C:len()<=0 then
			d = 64
		end
		a,b,c,d = b64:sub(a+1,a+1),b64:sub(b+1,b+1),b64:sub(c+1,c+1),b64:sub(d+1,d+1)
		s = s .. a .. b .. c .. d
	end
	reg.push(s)
end
def_funcs['decode64'] = function()
	local s = ''
	local a = reg.pop()
	local a = a:gsub(b64:sub(65,65), '')
	local lComp = ((a:len()/4)*3)
	local len = math.floor(lComp)
	local co = 0
	for A,B,C,D in a:gmatch"(.)(.?)(.?)(.?)" do
		local a,b,c,d = b64:find(A)-1,b64:find(B)-1,b64:find(C)-1,b64:find(D)-1
		local n = math.floor(a * (2^(6*3)) + b * (2^(6*2)) + c * (2^(6*1)) + d)
		a = n % 2^8
		b = math.floor(n/2^8) % 2^8
		c = math.floor(math.floor(n/2^8)/2^8) % 2^8
		a,b,c = string.char(a),string.char(b),string.char(c)
		local st = c .. b .. a
		st = st:sub(0,len - co)
		s = s .. st
		co = co + 3
	end
	reg.push(s)
end
def_funcs['frombase'] = function()
	local a,b = reg.pop(),reg.pop()
	local n = 0
	if(type(b)=='string')then
		while #b > 0 do
			local s = b:sub(1,1)
			b = b:sub(2,#b)
			if a == 64 then
				if(b64:find(s)-1 < 64) then
					s = b64:find(s)-1
				else
					s = 0
				end
			else
				s = s:byte()
				if s >= 48 and s <= 57 then
					s = string.char(s)
				else
					s = s - 55
				end
			end
			n = n * a + s
		end
	end
	reg.push(math.floor(n))
end
def_funcs['base'] = function()
	local a = reg.pop()
	local b = reg.pop()
	if(type(b)=='string')then
		b = tonumber(b)
	end
	if(type(b)=='table')then
	end
	if(type(b)=='number')then
		local s = ''
		while b > 0 do
			local n = math.floor(b % a)
			if a == 64 then
				n = b64:sub(n+1, n+1)
			else
				if n >= 10 then
					n = string.char(55 + n)
				else
					n = math.floor(n)
				end
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
		local a = a.clone()
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
	local a = reg.pop()
	if(type(a)=='string') then
		reg.push(a)
		reg.push('.')
		f['split']()
	elseif(type(a)=='number')then
		local b = reg.pop()
		local s = stack.new()
		if(type(b)=='function')then
			for i=1, a do
				reg.push(i)
				b()
				s.push(reg.pop())
			end
		end
		reg.push(s)
	end
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
def_funcs['rotate_r'] = function()
	local a = reg.pop()
	if type(a)=='string' then
		reg.push(a:sub(#a,#a)..a:sub(1,#a-1))
	elseif type(a)=='table' then
		local newStack = stack.new(a.size)
		a.apply(function(...)
			o = {...} -- I've cheated to get every value from stack a how I like it.
			newStack.push(o[#o])
			for i=1, #o-1 do
				newStack.push(o[i])
			end
		end)
		reg.push(newStack)
	elseif type(a)=='number' then

	end
end
def_funcs['rotate_l'] = function()
	local a = reg.pop()
	if type(a)=='string' then
		reg.push(a:sub(2,#a) .. a:sub(1,1))
	elseif type(a)=='table' then
		local newStack = stack.new(a.size)
		a.apply(function(...)
			o = {...} -- I've cheated to get every value from stack a how I like it.
			for i=2, #o do
				newStack.push(o[i])
			end
			newStack.push(o[1])
		end)
		reg.push(newStack)
	elseif type(a)=='number' then
		
	end
end
def_funcs['get'] = function()
	local a, b = reg.pop(), reg.pop()
	reg.push(b[a])
end
def_funcs['set'] = function()
	local a, b, c = reg.pop(),reg.pop(),reg.pop()
	c[b] = a
end
function truthy(val)
	local case = val
	if(type(case)=='number')then
		case = case ~= 0
	elseif type(case)=='string' then
		case = #case > 0
	else
		case = not not case
	end
	return case	
end
def_funcs['truthy'] = wrapFunc(truthy)

def_funcs['log'] = function()
	local a,b = reg.pop(),reg.pop() reg.push(math.log(b,a))
end
def_funcs['sin'] = function()
	reg.push(math.sin(reg.pop()))
end
def_funcs['cos'] = function()
	reg.push(math.cos(reg.pop()))
end
def_funcs['tan'] = function()
	reg.push(math.tan(reg.pop()))
end
def_funcs['asin'] = function()
	reg.push(math.asin(reg.pop()))
end
def_funcs['acos'] = function()
	reg.push(math.acos(reg.pop()))
end
def_funcs['atan'] = function()
	reg.push(math.atan(reg.pop()))
end
def_funcs['atan2'] = function()
	local a,b = reg.pop(),reg.pop() reg.push(math.atan2(b,a))
end
def_funcs['deg'] = function()
	reg.push(math.deg(reg.pop()))
end
def_funcs['rad'] = function()
	reg.push(math.rad(reg.pop()))
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
	return {i=#inp}
end
def_funcs['?'] = function()
	local case, if_true, if_false
	local funcs = {}
	while true do
		local v = reg.pop()
		if(type(v)=='function')then
			table.insert(funcs,1,v)
		else
			case = v
			break
		end
	end
	case = truthy(case)
	if case then
		if funcs[1] then funcs[1]() end
	else
		if funcs[2] then funcs[2]() end
	end
end
def_funcs[":"] = function()
	local func = reg.pop()
	local inc = reg.pop()
	local max = reg.pop()
	local min = reg.pop()
	for i=min, max, inc do
		reg.push(i)
		func()
	end
end
def_funcs[";"] = function()
	local func = reg.pop()
	while truthy(reg.pop()) do
		func()
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

def_funcs['for'] = function(i, inp, l, _, n)
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
		loops.push(n)
		reg.push(a) -- and give access to a.
	end
end
def_funcs['function'] = function(i,inp,l)
	local n = flow_to(i,inp,l).i
	local f = function()
		rpn(inp:sub(i+1,n),false,l)
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
def_funcs['while'] = function(i, inp, funcs, _, n)
	funcs['truthy'](i,inp) local case = reg.pop()
	if case then
		loops.push(n)
	else
		local t = flow_to(i,inp,funcs)
		return t
	end
end
def_funcs['while_peek'] = function(i, inp, funcs, _, n)
	reg.push(reg.peek())
	funcs['truthy'](i,inp) local case = reg.pop()
	if case then
		loops.push(n)
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
	print("CURRENT REG: ",reg)
	local a = true
	for k,v in pairs(mem) do
		a = a and print("CUSTOM MEMORY:")
		print(k, '=', v)
	end

end

-- Most of this is now Redundant. Yay!
flow = stack.new()
flow.push(def_funcs['if'])
flow.push(def_funcs['if_peek'])
flow.push(def_funcs['for'])
flow.push(def_funcs['while'])
flow.push(def_funcs['while_peek'])
flow.push(def_funcs['function'])

-- START SUGAR LOAD
local sugar = io.open('sugar.txt')
sugar = sugar:read('*a')
-- END SUGAR LOAD
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
		elseif def_funcs[key] then
			return def_funcs[key]
		elseif tonumber(key) then
			return function() reg.push(tonumber(key)) end
		elseif key:lower()=='true' then
			return function() reg.push(true) end
		elseif key:lower()=='false' then
			return function() reg.push(false) end
		elseif key:match"^`" then
			return function() reg.push(key:sub(2)) end
		elseif key:match'^~' then
			rpn(key:sub(2):gsub(".-[\128-\191]*","%0 "):gsub("((['\"]).-%2)",function(s)return s:gsub('(.)%s','%1')end):gsub("` (.)","`%1"),false,funcs)
		end
	end})
	local inString = false
	local usedQoute = ''
	local builtWord = ''
	local varType = ''
	local function stuff(i,n)
		if varType == 'String' and not (builtWord:match'^~') then
			reg.push(builtWord)
		else
			local f = funcs[builtWord]
			if f then
				local b,t = pcall(f, i, input, funcs, locals, n)
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
	local n = 0
	while i <= #input do
		local s = input:sub(i,i)
		if (s == '"' or s == "'") then
			if (s==usedQoute or not inString) then
				usedQoute = s
				inString = not inString
				varType = 'String'
				if builtWord:find("^~") then
					builtWord = builtWord .. s
				end
			else
				builtWord = builtWord..s
			end
		elseif not inString and s:find("%s") then
			i = stuff(i,n)
			n = i
		else
			builtWord = builtWord .. s
		end
		i = i + 1
	end
	stuff(#input,n)
	if doEchoStack then
		local val = reg.pop()
		while val~=nil do
			io.write(tostring(val))
			val = reg.pop()
			if val then print() end
		end
	end
end

rpn(input, true)