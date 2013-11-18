emu.registerbefore(function()
	local inp = input.get()
	local mouse = {
		x = inp.xmouse,
		y = inp.ymouse,
		l = inp.leftclick and "L" or "l",
		m = inp.middleclick and "M" or "m",
		r = inp.rightclick and "R" or "r",
	}
	emu.message("x: " .. mouse.x .. " y: " .. mouse.y .. " " .. mouse.l .. mouse.m .. mouse.r)
end)