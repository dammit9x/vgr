local value = 255
local x,y,tile = 0,0,0x10

function bit(p)
	return 2 ^ (p - 1) -- 1-based indexing
end

function hasbit(x, p)
	return x % (p + p) >= p
end

while true do
	for i=0,9 do
		local status = "false"
		if hasbit(value,bit(i)) then status = "true" end
		gui.text(x,y+i*tile,i.." "..status)
	end
	snes9x.frameadvance()
end
