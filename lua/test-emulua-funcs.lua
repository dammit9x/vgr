local fileoutput = true --console output if false
local filename = "functions.txt"
local str = ""

local function say(stuff)
	if fileoutput then str = str..tostring(stuff)
	else print(tostring(stuff))
	end
end

local function dump(name, t)
	say(name.."\n")
	if not t then say("(empty)") say("\n") return end
	for k in pairs(t) do say(k.."\n") end
	say("\n")
end

local e = emu or gens
dump("GLOBAL", _G)
say("'emu' is a "..type(emu)) say("\n")
dump("EMU", e)
dump("MEMORY", memory)
dump("GUI", gui)
dump("JOYPAD", joypad)
dump("JOYPAD KEYS:", joypad.get(1))
dump("INPUT", input)
dump("SAVESTATE", savestate)
dump("SOUND", sound)

e.message(tostring(joypad.get(1)))

if fileoutput then
	local file = io.open(filename, "w")
	file:write(str)
	file:close()
	print("output to", filename)
end

print("done running")