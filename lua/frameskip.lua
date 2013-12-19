--Frameskip detector Lua script, written by Dammit
--for use with Lua-equipped emulators: MAME-rr, FBA-rr, PSXjin, etc.
--last updated 5/11/2011

local game, old_timer_frame, start_of_unskipped_span, non_arcade
local arcade_game_list = {
	{ games = {"sf2"}, timer_frame_addr = 0xFF8ACF },
	{ games = {"sf2ce", "sf2hf"}, timer_frame_addr = 0xFF8ABF },
	{ games = {"ssf2"}, timer_frame_addr = 0xFF8CCF },
	{ games = {"ssf2t"}, timer_frame_addr = 0xFF8DCF },
	{ games = {"hsf2"}, timer_frame_addr = 0xFF8BFD },
	{ games = {"sfa"}, timer_frame_addr = 0xFFAE0A },
	{ games = {"sfa2", "sfz2al", "sfa3", "vsav", "vsav2", "vhunt2", "spf2t"}, timer_frame_addr = 0xFF810A },
	{ games = {"dstlk"}, timer_frame_addr = 0xFF9415 },
	{ games = {"nwarr"}, timer_frame_addr = 0xFF8E15 },
	{ games = {"sgemf"}, timer_frame_addr = 0xFF818A },
	{ games = {"xmcota", "msh", "mshvsf"}, timer_frame_addr = 0xFF4809 },
	{ games = {"xmvsf"}, timer_frame_addr = 0xFF5009 },
	{ games = {"mvsc"}, timer_frame_addr = 0xFF4009 },
	{ games = {"sfiii3"}, timer_frame_addr = 0x02011379 },
	{ games = {"sfz3ugd"}, timer_frame_addr = 0x0C420219 },
	{ games = {"capsnk"}, timer_frame_addr = 0x0C235202 },
	{ games = {"cvsgd"}, timer_frame_addr = 0x0C2356A2 },
	{ games = {"cvs2gd"}, timer_frame_ptr = function() --cvs2 addr depends on stage
		return memory.readdword(memory.readdword(0x0C05699C)) + memory.readword(0x0C05698C)
	end },
	{ games = {"mvsc2"}, timer_frame_addr = 0x0C2F8379 },
}

--There is no autodetection on other emulators. Put your current game last in the list.
non_arcade = { game = "Darkstalkers 3 PSX", timer_frame_addr = 0x1C38EA }
non_arcade = { game = "SFA2 PSX", timer_frame_addr = 0x190326 }
non_arcade = { game = "MSH PSX", timer_frame_addr = 0x091A91 }
non_arcade = { game = "CvSPro PSX", timer_frame_addr = 0x06E28E }
non_arcade = { game = "SF2 Turbo SNES", timer_frame_addr = 0x7E18F2 } --use snes9x-1.51

if fba or mame then
	emu.registerstart(function()
		game = nil
		for _, module in ipairs(arcade_game_list) do
			for _, shortname in ipairs(module.games) do
				if emu.romname() == shortname or emu.parentname() == shortname then
					game = module
					old_timer_frame = memory.readbyte(game.timer_frame_addr or game.timer_frame_ptr())
					start_of_unskipped_span = emu.framecount()
					print("tracking " .. emu.romname() .. " frameskip")
					return
				end
			end
		end
		print("not prepared for " .. emu.romname() .. " frameskip")
	end)
elseif non_arcade then
	game = non_arcade
	old_timer_frame = memory.readbyte(game.timer_frame_addr)
	start_of_unskipped_span = emu.framecount()
	print("tracking " .. non_arcade.game .. " frameskip")
end

while true do
	if not game then
		emu.frameadvance()
		return
	end

	--Prevent the frame timer from running out because different games refill it in different ways.
	--This also causes infinite match time.
	local addr = game.timer_frame_addr or game.timer_frame_ptr()
	memory.writebyte(addr, bit.band(0x0F, memory.readbyte(addr)) + 0x30)

	local new_timer_frame = memory.readbyte(addr)
	if new_timer_frame > old_timer_frame then
		--Ensure the timer always appears to decrease despite infinite time.
		old_timer_frame = old_timer_frame + 0x10
	end
	
	emu.message("timer decrease: " .. old_timer_frame - new_timer_frame)
	
	if old_timer_frame - new_timer_frame > 1 then
		local end_of_unskipped_span = emu.framecount()
		print(end_of_unskipped_span - start_of_unskipped_span)
		start_of_unskipped_span = end_of_unskipped_span
	end
	
	old_timer_frame = new_timer_frame
	emu.frameadvance()
end
