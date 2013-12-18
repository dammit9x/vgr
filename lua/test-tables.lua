local tile = 8
local elements = 10
local tab = {}
local timer=0

local function getdata()
	for k=#tab,1,-1 do
		table.remove(tab,k)
	end
	for k=1,elements do
		table.insert(tab,k)
		tab[k] = {x=2*tile*k, y=tile*k, val="foo"..k}
	end
end

local function showdata()
	for k,v in pairs(tab) do
		gui.text(tab[k].x,tab[k].y,tab[k].val)
	end
end

while true do
	showdata()
	if timer%100==0 then
		elements=elements-1
		getdata()
	end
	timer=timer+1
	gui.text(0,0xd0,#tab)
	snes9x.frameadvance()
end
