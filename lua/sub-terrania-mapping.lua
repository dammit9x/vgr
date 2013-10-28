print("Sub-Terrania mapmaking Lua script")
print("written by Dammit (September 15, 2011)")
print("for use with: http://code.google.com/p/gens-rerecording/")
print("* get the stage fully loaded and activate Graphics > Lock Pallete")
print("* run from a savestate just before the stage loads")
print("* hotkey 1/2: move camera by one screen width/height")
print("* hotkey 3/4: move camera by half screen width/height")
print()

local cheat = function() --unused
	memory.writedword(0xFF5ECC, 0x270000) --inf shield
	memory.writedword(0xFF5ED4, 0x290000) --inf fuel
	memory.writedword(0xFF5EDC, 0x260000) --inf mega
end

local screenshots, paused = false, false
local width  = {ship_offset = 0xA0, cam_offset = 0x0, count = 0.0, max = 
	{3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 2.0, 3.0, 7.0, 0.5}}
local height = {ship_offset = 0x44, cam_offset = 0x8, count = 0.0, max = 
	{3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 5.8, 4.6, 3.5, 0.5}}

local setcam = function()
	print("screen widths: " .. width.count .. " / heights: " .. height.count)
	local screen = {width = 0x140, height = 0xE0}
	screen.x = screen.width  * width.count
	screen.y = screen.height * height.count
	screen.filename = "screens/r" .. height.count+1 .. ",c" .. width.count+1 .. ".png"
	screen.x = screen.x +  width.cam_offset --compensate for camera's movement toward ship's facing direction
	screen.y = screen.y + height.cam_offset
	return screen
end
local screen = setcam()

local stage
local increment = function(dim)
	local diff = (dim.max[stage] or dim.max[1]) - dim.count
	if diff >= 1 then --increase by one screen if 1+ screens under the max
		return dim.count + 1
	elseif diff <= 0 then --set to zero if over the max
		return 0
	else --set to max if diff is less than one screen
		return dim.max[stage]
	end
end

input.registerhotkey(1, function()
	width.count = increment(width)
	screen = setcam()
end)

input.registerhotkey(2, function()
	height.count = increment(height)
	screen = setcam()
end)

input.registerhotkey(3, function()
	height.count = height.count%1 > 0 and height.count - 0.5 or height.count + 0.5
	screen = setcam()
end)

input.registerhotkey(4, function()
	width.count = width.count%1 > 0 and width.count - 0.5 or width.count + 0.5
	screen = setcam()
end)

emu.registerbefore(function()
	stage = memory.readword(0xFF003A)
	memory.writeword(0xFF80F0, screen.x) --foreground position
	memory.writeword(0xFF80F4, screen.y)
	memory.writeword(0xFF80E8, screen.x + width.ship_offset) --ship position
	memory.writeword(0xFF80EC, screen.y + height.ship_offset)
	memory.writeword(0xFF8206, 0x0800) --water level

	if memory.readdword(0xFF0000) == 0 and not paused then --map loaded
		emu.message()
		emu.pause()
		paused = true
	end
end)

savestate.registerload(function()
	paused = false
end)

emu.registerstart(function()
	paused = false
end)