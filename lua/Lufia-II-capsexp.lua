--lua script for Lufia II (USA) on snes9x rerecording+lua
--purpose: Raise the exp of each capsule monster to Maxim's exp level at the end of battles.
--Don't change the exp if the monster is not present or has more exp then Maxim.
--written by Dammit, 2/11/2009

local addr_exp_maxim   = 0x7e0c0c
local addr_exp_active  = 0x7e113e --Exp of active capsule monster
local addr_capsuletype = 0x7e11a3 --Index (0-6) for active capsule
local addr_exp_all     = 0x7ff1aa --Exp of all capsule monsters
local capsuleexp = {}

local function readexp(address)
	local expsum = 0
	for i=0,2 do expsum = expsum + memory.readbyte(address+i)*0x100^i end
	return expsum
end

local function addexp(address, experience)
	for j=0,6 do
		capsuleexp[j] = readexp(addr_exp_all+j*0x3)
		if capsuleexp[j] > 0 and capsuleexp[j] < experience then
			if memory.readbyte(addr_capsuletype) == j then
				for i=0,2 do memory.writebyte(addr_exp_active+i,memory.readbyte(addr_exp_maxim+i)) end
			else
				for i=0,2 do memory.writebyte(address+i+j*0x3,memory.readbyte(addr_exp_maxim+i)) end
			end
		end
	end
end

local oldexp = readexp(addr_exp_maxim)
local newexp = oldexp

while true do
	newexp = readexp(addr_exp_maxim)
	if newexp > oldexp then
		addexp(addr_exp_all, newexp)
	end
	oldexp = newexp
	snes9x.frameadvance()
end
