print("SimCity grid viewer, for snes9x-rr 1.43 ~ 1.51")
print("written by Dammit, 2/21/2009 ~ 6/2/2011") --dammit9x at hotmail dot com
--use with: http://code.google.com/p/snes9x-rr/
--purpose: display land values and other parameters on the playfield for the SimCity game
--discussion: http://tasvideos.org/forum/viewtopic.php?p=192582#192582

local hotkey = { --hotkey settings
	mode_inc    = {"rightbracket", "cycle view modes forward"},
	mode_dec    = {"leftbracket", "cycle view modes backward"},
	show_values = {"V", "show/hide grid values"},
	show_grid   = {"G", "show/hide the grid"},
	show_coords = {"C", "show/hide the map coordinates and city center"},
	num_format  = {"N", "switch between decimal & hex numbers"},
}

local globals = { --initial settings
	view_mode   = 1,
	show_values = true,
	show_grid   = true,
	show_coords = true,
	hex_numbers = false,
}

local label_x, label_y = 128, 216 --where to draw the view mode label
local coord_x, coord_y = 216, 216 --where to draw the map coordinates

local color = {
	["level 8"]     = 0xFF0000, --these are the in-game map colors
	["level 7"]     = 0xFF6300,
	["level 6"]     = 0xFFB500,
	["level 5"]     = 0xFFFF00,
	["level 4"]     = 0x00FF00,
	["level 3"]     = 0x00BD00,
	["level 2"]     = 0x008C00,
	["level 1"]     = 0x005A00,
	["powered"]     = 0xFF8400,
	["unpowered"]   = 0x00B500,
	["city center"] = 0xFF00FF,
	["dec text"]    = 0xFFFFFF, --grid values in decimal mode
	["hex text"]    = 0xFFFF00, --grid values in hexadecimal mode
	["label text"]  = 0x00FF00, --view mode label text
	["coord text"]  = 0x00FFFF, --coordinate text
}

local opacity = {
	fill    = 0x20, --inside of boxes
	outline = 0xA0, --outside of boxes
	text    = 0xFF,
}

--------------------------------------------------------------------------------

--prepare color settings
local fill, outline = {}, {}
local function map_colors(index, name)
	fill[index]    = bit.lshift(color[name], 8) + opacity.fill
	outline[index] = bit.lshift(color[name], 8) + opacity.outline
end

for i = 0xFF, 0, -1 do
	if i > 0xE0 then map_colors(i, "level 8")
	elseif i > 0xC0 then map_colors(i, "level 7")
	elseif i > 0xA0 then map_colors(i, "level 6")
	elseif i > 0x80 then map_colors(i, "level 5")
	elseif i > 0x60 then map_colors(i, "level 4")
	elseif i > 0x40 then map_colors(i, "level 3")
	elseif i > 0x20 then map_colors(i, "level 2")
	elseif i > 0x00 then map_colors(i, "level 1")
	else
		fill[i]    = 0 --blank/transparent
		outline[i] = 0
	end
end
map_colors(true, "powered")
map_colors(false, "unpowered")
map_colors("city center", "city center")
fill["dec text"]   = bit.lshift(color["dec text"], 8) + opacity.text
fill["hex text"]   = bit.lshift(color["hex text"], 8) + opacity.text
fill["label text"] = bit.lshift(color["label text"], 8) + opacity.text
fill["coord text"] = bit.lshift(color["coord text"], 8) + opacity.text

--memory addresses
local address = {
	x_tile   = 0x7E01BD, --camera position by upper-left tile
	y_tile   = 0x7E01BF,
	x_center = 0x7E0BA9, --coordinate of the city center
	y_center = 0x7E0BAA,
	playing  = 0x7E0012, --a game is in progress: draw coords
	hud      = 0x7E2210, --in-game HUD is shown: don't draw grid
	dark     = 0x7E90FF, --darkened BG: don't draw grid
	magnify  = 0x7E019B, --magnifier tool is open: draw grid
	time     = 0x7E0B51, --increments four times per game month; currently unused
}

--parameter values are stored here
local view = {
	{address = 0x7F6B00, sqsize = 2, bytes = 1, name = "Land value"},
	{address = 0x7F76B8, sqsize = 2, bytes = 1, name = "Crime"},
	{address = 0x7F8270, sqsize = 2, bytes = 1, name = "Pollution"},
	{address = 0x7F8E28, sqsize = 2, bytes = 1, name = "Population density"},
	{address = 0x7F99E0, sqsize = 2, bytes = 1, name = "Traffic"},
	{address = 0x7FA598, sqsize = 1, bytes = 1/8, name = "Power"},
	{address = 0x7FAB74, sqsize = 4, bytes = 1, name = "Land value modifier"},
	{address = 0x7FAE62, sqsize = 8, bytes = 2, name = "Growth rate"},
	{address = 0x7FAFE8, sqsize = 8, bytes = 1, name = "Police coverage"},
	{address = 0x7FB0AB, sqsize = 8, bytes = 1, name = "Fire coverage"},
}

local screenwidth, screenheight, tilesize = 256, 224, 8 --size in pixels
local mapwidth, mapheight = 120, 100 --size in tiles
local pressing_old = {} --array for keyboard input

for _, mode in ipairs(view) do
	mode.y_step = mapwidth / mode.sqsize
	mode.read = mode.bytes == 2 and memory.readwordsigned or memory.readbyte
end

print()
print("To enable the grid, hide the HUD with button Y or open the magnifier.")
print()
for _, v in pairs(hotkey) do
	print("Press the '" .. v[1] .. "' key to " .. v[2] .. ".")
end

function bit(p) --http://lua-users.org/wiki/BitwiseOperators
	return 2 ^ (p - 1)
end

function hasbit(x, p)
	return x % (p + p) >= p
end

local function draw_boxes()
	local x_tile, y_tile, mode = globals.x_tile, globals.y_tile, view[globals.view_mode]
	local y = 0
	while y < screenheight do
		local y_next = y + mode.sqsize * tilesize
		if y == 0 then
			y_next = (mode.sqsize - y_tile % mode.sqsize) * tilesize
		end
		if y_next > screenheight then
			y_next = screenheight
		end
		local x = 0
		while x < screenwidth do
			local x_next = x + mode.sqsize * tilesize
			if x == 0 then
				x_next = (mode.sqsize - x_tile % mode.sqsize) * tilesize
			end
			if x_next > screenwidth then
				x_next = screenwidth
			end
			if x_tile + x/tilesize >= 0 and y_tile + y/tilesize >= 0 --check the map boundaries
			and x_tile + x/tilesize < mapwidth and y_tile + y/tilesize < mapheight then
				local value = mode.read(mode.address + math.floor(
				(math.floor((x_tile + x/tilesize) / mode.sqsize)
				+ math.floor((y_tile + y/tilesize) / mode.sqsize) * mode.y_step) * mode.bytes))

				if globals.show_grid then
					if mode.read == memory.readwordsigned then
						if value > 0xFF then value = 0xFF end
						if value < -0xFF then value = -0xFF end
						value = math.floor((value + 0xFF) / 2)
					end
					if mode.bytes < 1 then
						value = hasbit(value, bit(8 - (x_tile + x/tilesize + (y_tile + y/tilesize) * mode.y_step) % 8))
					end
					gui.box(x, y, x_next-1, y_next-1, fill[value], outline[value])
				end

				if globals.show_values and value ~= 0 and mode.sqsize > 1 and
					x_next >= 2 * tilesize and y_next >= 2 * tilesize and
					x + 2 * tilesize <= screenwidth and y + 2 * tilesize <= screenheight then
					local color
					if globals.hex_numbers then
						value, color = string.format("%02X", value), fill["hex text"]
					else
						value, color = string.format("%d", value), fill["dec text"]
					end
					gui.text(x_next - value:len() * 4 - 1, y + 1, value, color)
				end

			end
			x = x_next
		end
		y = y_next
	end

	if globals.show_grid or globals.show_values then --show the label only with the grid or values active
		gui.text(label_x, label_y, mode.name, fill["label text"])
	end
end

local function draw_data()
	local x_tile, y_tile, x_center, y_center = globals.x_tile, globals.y_tile, globals.x_center, globals.y_center
	if globals.grid_ok then
		draw_boxes()
	end

	if globals.show_coords then --show the coordinates & city center
		gui.text(coord_x, coord_y, "(" .. x_tile .. ", " .. y_tile .. ")", fill["coord text"])

		local xdraw, ydraw = (x_center - x_tile) * tilesize, (y_center - y_tile) * tilesize
		if x_center < x_tile then
			xdraw = 0
		end
		if x_center >= x_tile + screenwidth/tilesize then
			xdraw = screenwidth - tilesize
		end
		if y_center < y_tile then
			ydraw = 0
		end
		if y_center >= y_tile + screenheight/tilesize then
			ydraw = screenheight - tilesize
		end
		gui.box(xdraw, ydraw, xdraw + 7, ydraw + 7, fill["city center"], outline["city center"])
	end
end

emu.registerafter(function()
	globals.game_playing = memory.readbyte(address.playing) > 0
	if not globals.game_playing then
		pressing_old = {}
		return
	end

	globals.grid_ok = memory.readbyte(address.dark) == 0 and 
		(memory.readword(address.hud) == 0x5555 or memory.readbyte(address.magnify) > 0)
	globals.x_tile, globals.y_tile = memory.readbytesigned(address.x_tile), memory.readbytesigned(address.y_tile)
	globals.x_center, globals.y_center = memory.readbyte(address.x_center), memory.readbyte(address.y_center)

	local pressing = input.get()

	if (globals.show_grid or globals.show_values) and globals.grid_ok then
		if pressing[hotkey.mode_inc[1]] and not pressing_old[hotkey.mode_inc[1]] then
			globals.view_mode = globals.view_mode >= #view and 1 or globals.view_mode + 1
		elseif pressing[hotkey.mode_dec[1]] and not pressing_old[hotkey.mode_dec[1]] then
			globals.view_mode = globals.view_mode == 1 and #view or globals.view_mode - 1
		end
	end
	if pressing[hotkey.show_values[1]] and not pressing_old[hotkey.show_values[1]] and globals.grid_ok then
		globals.show_values = not globals.show_values
	end
	if pressing[hotkey.show_grid[1]] and not pressing_old[hotkey.show_grid[1]] and globals.grid_ok then
		globals.show_grid = not globals.show_grid
	end
	if pressing[hotkey.show_coords[1]] and not pressing_old[hotkey.show_coords[1]] then
		globals.show_coords = not globals.show_coords
	end
	if pressing[hotkey.num_format[1]] and not pressing_old[hotkey.num_format[1]] and globals.show_values then
		globals.hex_numbers = not globals.hex_numbers
	end

	pressing_old = pressing
end)

gui.register(function()
	gui.clearuncommitted()

	if globals.game_playing then
		draw_data()
	end
end)
