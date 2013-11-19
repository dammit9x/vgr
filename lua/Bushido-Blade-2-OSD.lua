--[[
Lua script for Bushido Blade 2
Displays position, distance, time
Written by Dammit, March 2010 (dammit9x at hotmail dot com)

Use with: http://code.google.com/p/pcsxrr/
]]

local addr={
	x1=0xA9D68,y1=0xA9D70, --p1
	--x2=0xB40C0,y2=0xB40C8, --p2, VS mode
	x2=0xB28D4,y2=0xB28DC, --enemy, slash mode
	enemynum =0x0A38E2,
	enemytime=0x102350,
	totaltime=0x0A3858,
	respawntime=0x0A382E,
}

local draw={
	p1x=0x080,p1y=0xD0,
	p2x=0x1C0,p2y=0xD0,
	rx =0x120,ry =0xD0,
	timex=0x1D0,timey=0x28,
	lastx=0x1D0,lasty=0x08,
	nextx=0x1D0,nexty=0x30,
}

local x1,y1,x2,y2,r
local new,old,last={},{},{}
old.enemynum=100
old.enemytime=-1
old.totaltime=-1

emu.registerbefore(function()
	x1,y1=memory.readwordsigned(addr.x1),memory.readwordsigned(addr.y1)
	x2,y2=memory.readwordsigned(addr.x2),memory.readwordsigned(addr.y2)
	
	new.enemynum =memory.readbyte(addr.enemynum)
	new.enemytime=memory.readword(addr.enemytime)
	new.totaltime=memory.readword(addr.totaltime)
	if new.enemytime==0 then
		last.enemynum =old.enemynum-1
		last.enemytime=old.enemytime
		last.totaltime=old.totaltime
	end
end)

emu.registerafter(function()
	old.enemynum =new.enemynum
	old.enemytime=new.enemytime
	old.totaltime=new.totaltime
end)

gui.register(function()
	if x1 and y1 and x2 and y2 then
		r=math.sqrt((x2-x1)^2+(y2-y1)^2)
		gui.text(draw.p1x,draw.p1y,"("..x1..","..y1..")")
		gui.text(draw.p2x,draw.p2y,"("..x2..","..y2..")")
		gui.text(draw.rx,draw.ry,"Distance: "..string.format("%i",r))
	end
	if new.totaltime then gui.text(draw.timex,draw.timey,"Time: "..new.totaltime) end
	if last.enemynum then
		gui.text(draw.lastx,draw.lasty,"Enemy #"..last.enemynum..": "..last.enemytime.." ("..last.totaltime..")")
	end
	local respawntime=memory.readbyte(addr.respawntime)
	if respawntime>0 then
		gui.text(draw.nextx,draw.nexty,"Next in: "..60-respawntime)
	end
end)

while true do
	emu.frameadvance() --pcsx needs this for some reason
end