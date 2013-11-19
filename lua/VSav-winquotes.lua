-- vsav winquote dumper
-- use with FBA-rr, requires gd library
-- written by Dammit

local savenumber = 5 -- make a savestate in this slot at the "VS" screen, 2 players, with lives set to 1
local outdir = "winquotes" -- this folder must exist

local addr = { char = 0xff8782, color = 0xff87ae, quote = 0xff80d5, p1X = 0xff8410, p2X = 0xff8810, p2life = 0xff8852 }
local charlist = {
	"BBHood",
	"Demitri",
	"Talbain",
	"Victor",
	"Rapter",
	"Morrigan",
	"Anakaris",
	"Felicia",
	"Bishamon",
	"Rikuo",
	"Sasquatch",
	nil, --Rapter w/ chainsaw
	"QBee",
	"HsienKo",
	"Lilith",
	"Jedah",
}
require "gd"
local i={}

emu.speedmode("turbo")
for c,name in pairs(charlist) do
	savestate.load(savestate.create(savenumber)) -- load a state saved at the "VS" screen
	print("starting loop for " .. name .. "...")
	memory.writebyte(addr.char, c-1) -- set character
	memory.writebyte(addr.color, 0) -- set color to LP choice
	i = {}
	i["P1 Weak Punch"] = 1 -- press button to clear screen
	joypad.set(i)
	for n = 1,200 do emu.frameadvance() end -- wait until match is set up
	while memory.readword(addr.p2X) - memory.readword(addr.p1X) > 70 do -- hold forward until distance is close
		i = {}
		i["P1 Right"],i["P2 Left"] = 1,1
		joypad.set(i)
		emu.frameadvance()
	end
	memory.writeword(addr.p2life, 0) -- reduce p2's life
	i = {}
	i["P1 Weak Kick"] = 1 -- p1 kills p2
	joypad.set(i)
	for n = 1,320 do emu.frameadvance() end -- wait until winpose
	i = {}
	i["P1 Weak Punch"] = 1 -- press button to clear screen
	joypad.set(i)
	while memory.readword(addr.p1X) > 0 do emu.frameadvance() end -- wait until match is cleared
	local tempstate = savestate.create()
	savestate.save(tempstate) -- save a temp savestate
	for q = 1,15 do
		savestate.load(tempstate)
		memory.writebyte(addr.quote, q) -- force the desired quote
		for n = 1,70 do emu.frameadvance() end -- wait for quote to show up
		-- take the screenshot
		gd.createFromGdStr(gui.gdscreenshot()):png(outdir .. "/" .. name .. "-" .. string.format("%02d", q) .. ".png")
		print("saved screenshot: " .. outdir .. "/" .. name .. "-" .. string.format("%02d", q) .. ".png")
	end
end
emu.speedmode("normal")
print("done")
emu.pause()
