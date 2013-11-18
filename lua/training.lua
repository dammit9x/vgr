dofile("input-display.lua")

local interval=120 --2 seconds
local timer=interval

while true do
	emu.message("Next attack coming in: " .. timer)
	timer=timer-1
	if timer==0 then
		local i={}
		i["P2 Strong Punch"]=1
		joypad.set(i)
		timer=interval
	end
	emu.frameadvance()
end
