--lua script for Lufia II (USA) on snes9x rerecording+lua
--purpose: pause emulation whenever a text box is ready to be cleared
--written by Dammit, 2/11/2009

--local lineaddress = 0x7e125c--0x7fd087--The number of lines in the dialog box
local statusaddress = 0x7e0075
local oldstatus,status = 0,0

while true do
	status = memory.readbyte(statusaddress)
	if status == 0 and oldstatus == 65 then	snes9x.pause()	end
	oldstatus = status
	snes9x.frameadvance()
end