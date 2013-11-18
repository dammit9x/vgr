--[[
Audio dump helper script for Bushido Blade 2 TAS
Written by Dammit, March 2010 (dammit9x at hotmail dot com)
Thanks to mz and BadPotato

Use with: http://code.google.com/p/pcsxrr/

Problem:
Playing the movie with a good-sounding audio plugin causes desync after every kill.

General solution:
Step 1: Using the sync-safe plugin, save state after every potential desync.
Step 2: Using the good-sounding plugin, load those states at the correct times.

Instructions:
Step 1: Choose the TAS plugin and set dumpmode to false.
Start the script and play the pxm to the end.

Step 2: Choose a good plugin and set dumpmode to true.
Start the script and play the pxm while dumping audio/video.
]]

local dumpmode=true --create savestates if false, load them if true
local path="./sstates/"
local enemyaddr=0xA38E2

local oldenemy,newenemy=100,0

emu.registerbefore(function()
	newenemy=memory.readbyte(enemyaddr)
	if newenemy>oldenemy then
		if dumpmode then --playback: load the prepared savestates
			local savestatefile=io.open(path.."BB2-audio."..string.format("%03i",newenemy),"rb")
			local savedata=savestatefile:read("*all")
			io.close(savestatefile)
			
			savestatefile=io.open(path.."BB2.pxm.008","wb")
			savestatefile:write(savedata)
			io.close(savestatefile) 
		
			savestate.load(savestate.create(9))
			
		else --preparation: create the savestates
			savestate.save(savestate.create(9))
			
			local savestatefile=io.open(path.."BB2.pxm.008","rb")
			local savedata=savestatefile:read("*all")
			io.close(savestatefile)

			savestatefile=io.open(path.."BB2-audio."..string.format("%03i",newenemy),"wb")
			savestatefile:write(savedata)
			io.close(savestatefile)
			
		end
	end
	oldenemy=newenemy
end)

while true do
	emu.frameadvance()
end