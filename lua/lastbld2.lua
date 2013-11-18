local offset,life,meter={},{},{}

--life.p1  = 0.5
life.p2  = 0.5
--meter.p1 = 1
meter.p2 = 1

--dofile("input-display.lua", "r")

emu.registerbefore(function()
	offset.p1, offset.p2 = memory.readdword(0x10E344), memory.readdword(0x10E348)
	for p,v in pairs(life) do
		if v then memory.writeword(offset[p]+0x17E, life[p]*0x80) end
	end
	for p,v in pairs(meter) do
		if v then memory.writebyte(offset[p]+0x17D, meter[p]*0x40) end
	end
end)