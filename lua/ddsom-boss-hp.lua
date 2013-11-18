dofile("input display.lua","r")

local hpaddr = 0xffcb20
local newhp = memory.readword(hpaddr)
local oldhp = newhp
local newmoviestate = movie.mode()
local oldmoviestate = newmoviestate

fba.registerafter( function()

	newhp = memory.readword(hpaddr)
	if newhp ~= oldhp and newhp ~= 0xff then
		print(newhp..'\t'..oldhp-newhp..'\t'..fba.framecount())
	end
	oldhp = newhp

	newmoviestate = movie.mode()
	if newmoviestate ~= oldmoviestate then
		print("GMV status:",newmoviestate)
	end
	oldmoviestate = newmoviestate

end)

fba.registerbefore( function()
	if fba.framecount() == 0 then
		print("Starting over.")
	end
end)