--lua script for gens rerecording+lua: http://code.google.com/p/gens-rerecording/
--purpose: display info on screen, and allow option cheat mode and speed tracking for the Target Earth game
--written by Dammit 9/9/2009 (dammit9x at hotmail dot com)

local address = { xcam=0xfff098, ycam=0xfff09a, xrel=0xffb03c, yrel=0xffb038, angle=0xffb04a,
	control=0xff8001, maxhp=0xff8099, cool=0xffb749, ammo=0xffd09b, slot=0xff8097, sprite=0xffb030 }
local sprite = { id=0x1, x=0xc, y=0x8, hp=0x14, hpb=0x1b }
local draw = {	xspeed=0x130, yspeed=0xd0, speedinc=0x8, xcheat=0x8, ycheat=0x0,
	xcoord=0x70, ycoord=0xc4, xcool=0x120, ycool=0xc0 }
local buffersize,maxslots,interval = 19,29,0x2c
local ally,enemy = "green","red"
local mode = { cheat=false, drawspeed=false }

input.registerhotkey(1,function() --lua hotkey 1 toggles cheat mode
	if not mode.cheat then mode.cheat = true
	else mode.cheat = false
	end
	gui.redraw()
end)
input.registerhotkey(2,function() --lua hotkey 2 toggles drawing speed
	if not mode.drawspeed then mode.drawspeed = true
	else mode.drawspeed = false
	end
	gui.redraw()
end)

local xvalue,yvalue = {},{}
local function readpos()
	xvalue[1] = memory.readword(address.xcam) + memory.readword(address.xrel)
	yvalue[1] = memory.readword(address.ycam) + memory.readword(address.yrel)
end

savestate.registersave(function(slotnumber) -- save out the arrays
  return xvalue,yvalue
end)

savestate.registerload(function(slotnumber,x,y) -- load in the arrays
	local x,y,s = savestate.loadscriptdata(slotnumber) 
	xvalue = x or {}
	yvalue = y or {}
	stopcount = s or 0
end)

readpos()
gens.registerafter( function()
	if memory.readbyte(address.control) == 0 then
		for n=buffersize,2,-1 do
			xvalue[n] = xvalue[n-1]
			yvalue[n] = yvalue[n-1]
		end
		readpos() --update position data every frame
		if mode.cheat then
			memory.writebyte(address.sprite+sprite.hp,memory.readbyte(address.maxhp))
			memory.writebyte(address.ammo+memory.readbyte(address.slot)*2,0x50)
			memory.writebyte(address.cool,0)
		end
	end
end)

gui.register( function()
	if mode.cheat then gui.text(draw.xcheat,draw.ycheat,"CHEAT","red") end
	
	if memory.readbyte(address.control) == 0 then
	
		gui.text(draw.xcoord,draw.ycoord,"("..xvalue[1]..","..yvalue[1]..")")
		
		local cool = memory.readbyte(address.cool)
		if cool > 0 then gui.text(draw.xcool,draw.ycool,cool,"yellow") end
		
		for slot=0,maxslots do
			local id = memory.readbytesigned(address.sprite+sprite.id+slot*interval)
			if id ~= 0 then
				local hp = memory.readbytesigned(address.sprite+sprite.hp+slot*interval)
				local x = memory.readwordsigned(address.sprite+sprite.x+slot*interval)
				local y = memory.readwordsigned(address.sprite+sprite.y+slot*interval)
				if x > -0x30 and x < 0x180 then
					local color = enemy
					if slot < 10 then color = ally end
					if slot == 29 then
						local hpb = memory.readbytesigned(address.sprite+sprite.hpb+slot*interval)
						gui.text(x,y-0x18,hpb..","..hp,color) --some bosses have extra hp
					else gui.text(x,y-0x18,hp,color)
					end
					--gui.text(x,y-0x18,slot..","..hp,color)
				end
			end
		end

		if mode.drawspeed then
			gui.text(draw.xspeed,draw.yspeed,"X")
			gui.text(draw.xspeed,draw.yspeed+draw.speedinc,"Y")
			for n=2,#xvalue do
				local dx = xvalue[n-1]-xvalue[n]
				gui.text(draw.xspeed-0x10*(n-1),draw.yspeed,dx)
				local dy = yvalue[n-1]-yvalue[n]
				gui.text(draw.xspeed-0x10*(n-1),draw.yspeed+draw.speedinc,dy)
			end
		end
		
	end
end)