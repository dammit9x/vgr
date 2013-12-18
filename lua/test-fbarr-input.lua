print(joypad.get())

local key="W"
local lastframe=nil

function Fn()
--[[
    local T= input.get()
    local Count= 0
    for k,v in pairs(T) do
        Count= Count+ 1
        gui.text(1,8*Count,k)
    end
		]]
		local now=input.get()[key]
		if now and not lastframe then
			print("You pressed the '" .. key .. "' hotkey.")
		end
		lastframe=now
end
gui.register(Fn)

while true do
	emu.frameadvance()
end