local address = {enemy=0xFFB090, xcam=0xFF01A8, ycam=0xFF01AA}
local ex,ey,ehp = 0x0,0x2,0xC
local maxslots,interval = 9,0x80

gui.register ( function()
	for slot = 0,maxslots do
		local hp = memory.readwordsigned(address.enemy+ehp+slot*interval)
		if hp > 0 then
			local x = memory.readwordsigned(address.enemy+ex+slot*interval)
			local y = memory.readwordsigned(address.enemy+ey+slot*interval)
			gui.text(x-memory.readword(address.xcam),y-memory.readword(address.ycam),hp)
		end
	end
end)