--[[
print(joypad.getanalog(1)["xleft"])
joypad.setanalog(1, {["xleft"] = 99})
print(joypad.getanalog(1)["xleft"])
]]

emu.registerbefore(function()
	joypad.setanalog(1, {["xleft"] = 99})
end)

emu.registerafter(function()
end)

while true do
		emu.message("foo")
		joypad.set(1,{start=true,select=true,x=true,circle=true,square=true,triangle=true,right=true,left=true,up=true,down=true})
		joypad.set(1,{l1=true,l2=true,r1=true,r2=true})
		emu.message(string.format("XL = %+04d, YL = %+04d, XR = %+04d, YR = %+04d",
			joypad.getanalog(1)["xleft"]-0x80,joypad.getanalog(1)["yleft"]-0x80,
			joypad.getanalog(1)["xright"]-0x80,joypad.getanalog(1)["yright"]-0x80))
		emu.frameadvance()
end
