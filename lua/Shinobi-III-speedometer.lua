--lua script for gens rerecording+lua: http://code.google.com/p/gens-rerecording/
--purpose: display character speed frame by frame and count frames with no movement for the Shinobi III game
--written by Dammit 3/23/2009; last updated 4/26/2009 (dammit9x at hotmail dot com)
--with help and support from nitsuja
--discussion: http://tasvideos.org/forum/t/7988

local Xaddress,Yaddress=0xFF414D,0xFF4151
local goodspeed,scale = 0x300,0x100
local buffersize = 24
local form = "%3.2f" --format to display the numbers
local speeddrawX,speeddrawY,speeddrawXinc = 0x08,0xe0,0x18
local stopdrawX,stopdrawY = 0x130,0xd0
local ok,bad,good,nocontrol = "white","red","green","blue"

local Xvalue,Yvalue = {},{}
local function readX()
	Xvalue[1] = memory.readlong(Xaddress)
end
local function readY()
	Yvalue[1] = memory.readlong(Yaddress)
end

local drawXspeed,drawYspeed = true,false
input.registerhotkey(1,function() --press lua hotkey 1 cycle between drawing X, X and Y, or neither
  if drawXspeed and not drawYspeed then drawYspeed = true
	elseif drawYspeed then drawXspeed,drawYspeed = false,false
	elseif not drawXspeed then drawXspeed = true
	end
end)

local stopcount,drawstopcount = 0,true
input.registerhotkey(2,function() --press lua hotkey 2 to switch/reset the stop counter
	if drawstopcount then drawstopcount = false
	else
		stopcount = 0
		drawstopcount = true
	end
end)

savestate.registersave(function(slotnumber) -- save out the arrays
  return Xvalue,Yvalue,stopcount
end)

savestate.registerload(function(slotnumber,x,y) -- load in the arrays
	local x,y,s = savestate.loadscriptdata(slotnumber) 
	Xvalue = x or {}
	Yvalue = y or {}
	stopcount = s or 0
end)

readX()
readY()
gens.registerafter( function()
	for n=buffersize,2,-1 do
		Xvalue[n] = Xvalue[n-1]
	end
	readX()
	for n=buffersize,2,-1 do
		Yvalue[n] = Yvalue[n-1]
	end
	readY()
end)

gui.register( function()
	if drawXspeed then
		gui.text(speeddrawX,speeddrawY+0x8,"X")
		for n=2,#Xvalue do
			local diff = Xvalue[n-1]-Xvalue[n]
			local speedcolor = bad
			if Xvalue[1] == 0 then speedcolor = nocontrol
			elseif math.abs(diff) == goodspeed then speedcolor = ok
			elseif math.abs(diff) > goodspeed then speedcolor = good
			end
			gui.text(speeddrawX,speeddrawY-0x8*n,string.format(form,diff/scale),speedcolor)
		end
	end
	
	if drawYspeed then
		gui.text(speeddrawX+speeddrawXinc,speeddrawY+0x8,"Y")
		for n=2,#Yvalue do
			local diff = Yvalue[n-1]-Yvalue[n]
			local speedcolor = ok
			if Yvalue[1] == 0 then speedcolor = nocontrol
			elseif diff < 0 then speedcolor = good
			end
			gui.text(speeddrawX+speeddrawXinc,speeddrawY-0x8*n,string.format(form,diff/scale),speedcolor)
		end
	end
	
	if drawstopcount then
		local stopcolor = bad
		if Xvalue[1] == 0 then stopcolor = nocontrol end
		gui.text(stopdrawX,stopdrawY,stopcount,stopcolor)
		if Xvalue[1] ~= 0 and Xvalue[2] == Xvalue[1] then stopcount = stopcount+1 end
	end
end)