print("Experimental Lua script for Battle Master (Genesis)")
print("Written by Dammit, last updated 1/13/2011")
print("http://www.gamefaqs.com/genesis/586050-battle-master/faqs/29225")
print()
print("Lua hotkey 1: toggle memviewer")
print("Lua hotkey 2: cycle memviewer profiles")
print("Lua hotkey 3: cycle parley/travel/default")
print("Lua hotkey 4: report stage enemies & items")
print()

local mode = {
  skip_lag       = true,
  autofire       = 10,
  parley_travel  = false,
  no_hostility   = true,
  full_hp        = false,
  infinite_GP    = false,
	--stage_select   = 32,
  skip_crown     = false,
  draw_HUD       = true,
  draw_memviewer = false,
  debug_damage   = false,
	jewel_read     = false,
}

--------------------------------------------------------------------------------
local active, current_stage, current_enemies, melee_id, missile_id, items_base
local address = {
	xcam         = 0xff0216,
	ycam         = 0xff0218,
	items_base   = 0xff9e7a,
	input_masked = 0xffba13,
	input        = 0xffba14,
	items_ptr    = 0xffba24,
	race_class   = 0xffba48,
	fight_mode   = 0xffba4f,
	max_hp       = 0xffba51,
	enemies      = 0xffba62,
	quota        = 0xffba64,
	damage_mod   = 0xffba7c,
	curr_stage   = 0xffba83,
	dest_stage   = 0xffba84,
	crown_pieces = 0xffba9e,
	active       = 0xffbaac,
	password     = 0xffc5f4,
	inventory    = 0xffc65e,
	groups2      = 0xffcc5a,
	groups       = 0xffcfa4,
	char_base    = 0xffd764,
	attk_base    = 0xffe200,
	race_table   = 0x01184C,
	melee_table  = 0x013746,
	missile_table= 0x0136aa,
}
local char_offset = {
	x_pos   = 0x00, --word
	y_pos   = 0x02, --word
	group   = 0x0a, --word
	race    = 0x0c,
	layer   = 0x0d,
	hp      = 0x0e,
	morale  = 0x0f,
	wounded = 0x11, --bitwise
	missile = 0x13,
	facing  = 0x16,
	number  = 0x18,
	space   = 0x1c,
}
local attk_offset = {
	x_pos   = 0x0, --word
	y_pos   = 0x2, --word
	weap_id = 0x4, --word
	attacker= 0x6, --word, offset from char_base
	facing  = 0x8,
	status  = 0x9, --bitwise
	layer   = 0xa,
	missile = 0xb,
	skill   = 0xc,
	damage  = 0xd,
	space   = 0xe,
}
local group_offset = {
	group_no    = 0x00, --word
	leader_area = 0x04, --word
	GP          = 0x06, --word
	leader_x1   = 0x08, --word
	leader_y1   = 0x0a, --word
	leader_x2   = 0x0c, --word
	leader_y2   = 0x0e, --word
	leader_x3   = 0x10, --word
	leader_y3   = 0x12, --word
	weapon      = 0x2c, --word
	missile     = 0x2e, --word
	armor       = 0x30, --word
	race        = 0x33,
	eq_morale   = 0x34,
	skill       = 0x35,
	members     = 0x36,
	formation   = 0x37,
	hostility   = 0x38, --bitwise, bit 0
	leader_face = 0x39,
	melee       = 0x3d,
	space       = 0x40,
}
local group2_offset = {
	max_hp      = 0x10,
	space       = 0x16,
}
local item_offset = {
	type   = 0x0, --word
	x_pos  = 0x2, --word
	y_pos  = 0x4, --word
	cost   = 0x6, --word
	name   = 0x8, --word
	number = 0xa,
	layer  = 0xb,
	plus   = 0xc,
	hidden = 0xd, --bitwise, bit 7
	space  = 0xe,
}
local nchars = 0x60

--------------------------------------------------------------------------------
local HUD_transparency = 0xc0
HUD_transparency = AND(0xff, HUD_transparency)

local function damage_mod(group, weapon_id, rom_table)
	local mod = memory.readword(address.groups + group + group_offset.armor)
	mod = memory.readword(items_base + mod + 0x2)
	mod = (AND(mod, 0x0fff) + weapon_id) * 2
	mod = memory.readwordsigned(rom_table + mod)
	return mod
end

local function HUD(go)
	if not active or not go then
		return
	end
	local quota = AND(0xff, memory.readword(address.quota))
	gui.text(0x0f8, 0xd2, "enemies: " .. current_enemies .. " (" .. quota .. ")", 0xff0000ff)
	gui.text(0x102, 0xda, "stage #" .. current_stage, 0x00ffffff)
	local cam = {
		x = memory.readword(address.xcam),
		y = memory.readword(address.ycam),
		layer = memory.readbyte(address.char_base + char_offset.layer),
	}
	for n = 0, nchars-1 do --characters
		local char_base = address.char_base + char_offset.space * n
		local x = memory.readword(char_base + char_offset.x_pos) - cam.x
		local y = memory.readword(char_base + char_offset.y_pos) - cam.y
		local same_layer = memory.readbyte(char_base + char_offset.layer) == cam.layer
		local group = memory.readwordsigned(char_base + char_offset.group)
		local race = memory.readbyte(char_base + char_offset.race)
		local hp = memory.readbyte(char_base + char_offset.hp)
		local morale = memory.readbyte(char_base + char_offset.morale)
		local skill = memory.readbyte(address.groups + group + group_offset.skill)
		local armor = memory.readwordsigned(address.groups + group + group_offset.armor)
		armor = AND(0xf, memory.readword(address.items_base + armor))
		local weapon = memory.readwordsigned(address.groups + group + group_offset.weapon)
		weapon = AND(0xf, memory.readword(address.items_base + weapon))
		local missile = memory.readwordsigned(address.groups + group + group_offset.missile)
		missile = missile < 0 and "-" or AND(0xf, memory.readword(address.items_base + missile))
		local color = char_base == address.char_base and 0x00ff0000 + HUD_transparency --player char
			or group == 0 and 0xffff0000 + HUD_transparency --troops
			or 0xff00ff00 + HUD_transparency --enemies
		if x > -0x08 and x < 0xb8 and y > 0 and y < 0xd0 and same_layer and group >= 0 then
			gui.text(x+0x0a, y-0x12, string.format("%d(%d)",hp,skill), color)
			--gui.text(x+0x0a, y-0x12, string.format("%d(%03x)",hp,group), color)
			--gui.text(x+0x0a, y-0x12, string.format("%04X,%02x,%d", AND(0xffff, char_base), group, race), color)
			if group > 0 then
				local melee_mod = damage_mod(group, melee_id, address.melee_table)
				local missile_mod = damage_mod(group, missile_id, address.missile_table)
				gui.text(x+0x0a, y-0x08, string.format("%d/%d [%s%s%s]",melee_mod,missile_mod,armor,weapon,missile), 0xff000000 + HUD_transparency)
			end
		end
	end
	for n = 0, nchars-1 do --attacks
		local attk_base = address.attk_base + attk_offset.space * n
		local x = memory.readwordsigned(attk_base + attk_offset.x_pos) - cam.x
		local y = memory.readwordsigned(attk_base + attk_offset.y_pos) - cam.y
		local same_layer = memory.readbyte(attk_base + attk_offset.layer) == cam.layer
		local damage = memory.readbytesigned(attk_base + attk_offset.damage)
		if x > 0 and x < 0xc0 and y > 0 and y < 0xd0 and same_layer then
			gui.text(x + 0xc, y, damage, 0xff000000 + HUD_transparency)
		end
	end
end

--------------------------------------------------------------------------------
memprofile = {
	{address.attk_base,     attk_offset.space,    "attacks"},
	{address.items_base,    item_offset.space,    "stage items/triggers"},
	{address.inventory,     item_offset.space,    "inventory"},
	{address.char_base,     char_offset.space/2,  "chars"},
	{address.groups,        group_offset.space/4, "group properties 1"},
	{address.groups2,       group2_offset.space,  "group properties 2"},
	--{address.melee_table,   0x10,                 "melee damage mod table"},
	--{address.missile_table, 0x10,                 "missile damage mod table"},
	--{address.race_table,    0x10,                 "racial properties"},
	--{address.password,      0xd,                  "password"},
}
local memarray, start_addr, rowsize, class
local rows = 10
local memprofileindex = 1

local function setmemprofile(go)
	if not go then
		return
	end
	local n = memprofileindex
	memprofileindex = n < #memprofile and n + 1 or 1
	start_addr, rowsize, class = memprofile[n][1], memprofile[n][2], memprofile[n][3]
	memarray = {}
	for a = start_addr, start_addr + rowsize*rows - 1 do
		table.insert(memarray, {
			x = 0x10 + (a-start_addr)%rowsize * 0x10,
			y = 0x10 + math.floor((a-start_addr)/rowsize) * 0x10,
			addr = a,
		})
	end
end
setmemprofile(true)

input.registerhotkey(1, function()
	mode.draw_memviewer = not mode.draw_memviewer
end)
input.registerhotkey(2, function()
	setmemprofile(mode.draw_memviewer)
end)

local function memviewer(draw)
	if not draw then
		return
	end
	gui.text(0, 0, string.format("%06x", start_addr) .. ": " .. class, 0x00ff00ff)
	for n = 0, rowsize-1 do
		gui.text(0x10 + n*0x10, 0x8, string.format("%02X", n), 0xffff00ff)
	end
	for n = 0, rows-1 do
		gui.text(0x0, 0x10 + n*0x10, string.format("%02X", n*rowsize), 0xffff00ff)
	end
	for _,v in ipairs(memarray) do
		--gui.text(v.x, v.y, string.format("%3d", memory.readbyte(v.addr)))
		gui.text(v.x, v.y, string.format("%02x", memory.readbyte(v.addr)))
	end
end

--------------------------------------------------------------------------------
local race_list = {
	[ 0] = {"Human"},
	[ 1] = {"Elf"},
	[ 2] = {"Dwarf"},
	[ 3] = {"Orc"},
	[ 4] = {"Scorpion"},
	[ 5] = {"Spider"},
	[ 6] = {"Dragonfly"},
	[ 7] = {"Chomper"},
	[ 8] = {"Snake"},
	[ 9] = {"Ghost"},
	[10] = {"Bat"},
	[11] = {"Fireball"},
	[12] = {"Giant eye"},
	[13] = {"Will-o-wisp"},
	[14] = {"Chomper"},
	[15] = {"Fireball"},
	[20] = {"Ogre"},
	[21] = {"Troll"},
	[22] = {"Armored giant"},
	[23] = {"Dragon"},
	[24] = {"Ogre"},
	[26] = {"Giant beetle"},
	[27] = {"Giant spider"},
	[29] = {"Dragonfly"},
}
for k,v in pairs(race_list) do
	if v[1]:sub(-1) == "f" then
		v[2] = v[1]:sub(1,-2) .. "ves"
	elseif v[1]:sub(-1) == "y" then
		v[2] = v[1]:sub(1,-2) .. "ies"
	else
		v[2] = v[1] .. "s"
	end
	v[1] = v[1]:lower() .. string.rep(" ", 14-string.len(v[1]))
	v[2] = v[2]:lower() .. string.rep(" ", 14-string.len(v[2]))
end

local formation_list = {
	[0] = "column",
	[1] = "wedge ",
	[2] = "line  ",
	[3] = "single",
	[4] = "open  ",
	[5] = "huddle",
}
local table_end = "+" .. string.rep("-", 26) .. "+" .. string.rep("-", 16) .. "+" .. string.rep("-", 33) .. "+"

input.registerhotkey(4, function()
	print()
	print("stage " .. (current_stage or memory.readbyte(address.curr_stage)))
	local total = 0
	print(table_end)
	for n = 1, 0x1e do --required for every group
		local offset = n*group_offset.space
		local addr = address.groups + offset
		local group_no = memory.readwordsigned(addr + group_offset.group_no)
		local race = memory.readbytesigned(addr + group_offset.race)
		if race >= 0 and group_no >= 0 then
			local group_size = memory.readbyte(addr + group_offset.members)
			race = race_list[race] and (group_size > 1 and race_list[race][2] or race_list[race][1]) or "race #" .. race .. "\t"
			total = total + group_size
			local formation = AND(0xf, memory.readbyte(addr + group_offset.formation))
			formation = formation_list[formation]
			local max_hp = memory.readbyte(address.groups2 + (group_no-1)*group2_offset.space + group2_offset.max_hp)
			local skill = memory.readbyte(addr + group_offset.skill)
			local item_base = address.items_base + memory.readword(addr + group_offset.armor)
			local item_type = AND(0xf, memory.readword(item_base))
			local item_plus = memory.readbyte(item_base + item_offset.plus)
			local armor = "[A" .. item_type .. "]" .. (item_plus > 9 and "" or " ") .. "(+" .. item_plus .. ")"
			item_base = address.items_base + memory.readword(addr + group_offset.weapon)
			item_type = AND(0xf, memory.readword(item_base))
			item_plus = memory.readbyte(item_base + item_offset.plus)
			local weapon = "[W" .. item_type .. "]" .. (item_plus > 9 and "" or " ") .. "(+" .. item_plus .. ")"
			local missile = "         "
			item_base = memory.readwordsigned(addr + group_offset.missile)
			if item_base > 0 then
				item_base = address.items_base + item_base
				item_type = AND(0xf, memory.readword(item_base))
				item_plus = memory.readbyte(item_base + item_offset.plus)
				missile = "[M" .. item_type .. "]" .. (item_plus > 9 and "" or " ") .. "(+" .. item_plus .. ")"
			end
			--print(string.format("#%02d\t0x%03x",group_no,offset))
			print(string.format("| %2d %s %s | %3d hp  %3d sk | %s  %s  %s |", group_size,race,formation,max_hp,skill,armor,weapon,missile))
		end
	end
	print(table_end)
	print(total .. " enemies")
	
	total = 0
	local n_items = memory.readbyte(memory.readdword(address.items_ptr) + 1)
	for n = 0, n_items-1 do
		local offset = n*item_offset.space
		local addr = address.items_base + offset
		local item_type = memory.readword(addr)
		local hidden = memory.readbyte(addr + item_offset.hidden)
		local cost = memory.readwordsigned(addr + item_offset.cost)
		local name = memory.readwordsigned(addr + item_offset.name)
		local x_pos = memory.readwordsigned(addr + item_offset.x_pos)
		local y_pos = memory.readwordsigned(addr + item_offset.y_pos)
		local layer = memory.readbyte(addr + item_offset.layer)
		if item_type < 0x1000 then
			local icon
			if item_type < 25 then
				icon = "coins"
			elseif item_type < 50 then
				icon = "pouch"
			elseif item_type < 100 then
				icon = "sack"
			else
				icon = "chest"
			end
			print(string.format("#%02d $%04x\t%d GP %s\t($%04x,$%04x,$%02x)\t$%02x",n,offset,item_type,icon,x_pos,y_pos,layer,hidden))
			total = total + item_type
		elseif AND(item_type, 0xf000) ~= 0x4000 and AND(item_type, 0xf000) ~= 0x5000
			and AND(item_type, 0xf000) ~= 0x7000 and AND(item_type, 0xf000) ~= 0x9000 then
			if AND(hidden, 0xf0) == 0x80 then
				print(string.format("#%02d $%04x\thidden item: $%04x ($%04x,$%04x,$%02x) $%02x",n,offset,item_type,x_pos,y_pos,layer,hidden))
				--memory.writebyte(addr + 0xd, hidden - 0x40)
			end
			if cost <= 0 and name > 0 then
				print(string.format("#%02d $%04x\tunbuyable: $%04x ($%04x,$%04x,$%02x) $%02x",n,offset,item_type,x_pos,y_pos,layer,hidden))
				memory.writeword(addr + item_offset.cost, 1)
			end
		end
	end
	print("total " .. total .. " GP, " .. n_items .. " items/triggers")
end)

--------------------------------------------------------------------------------
if mode.debug_damage then
	local dmg = {}
	memory.registerexec(0x5f7c, function() --defender's armor type was just loaded
		dmg.attk_base = AND(0xffffff, memory.getregister("a0"))
		dmg.attacker = AND(0xffffff, memory.getregister("a2"))
		dmg.a_group = memory.readword(dmg.attacker + char_offset.group)
		dmg.weapon = memory.readword(dmg.attk_base + attk_offset.weap_id)
		dmg.a_plus = memory.readbyte(dmg.attk_base + attk_offset.damage)
		dmg.a_skill = memory.readbyte(dmg.attk_base + attk_offset.skill)
		dmg.a_race = memory.readbyte(address.groups + dmg.a_group + group_offset.race)
		dmg.a_lead = memory.readbyte(address.groups + dmg.a_group + group_offset.formation)
		--if a_group ~= 0 then return end

		dmg.armor_base = AND(0xffffff, memory.getregister("a3"))
		dmg.defender = AND(0xffffff, memory.getregister("a6"))
		dmg.d_group = memory.readword(dmg.defender + char_offset.group)
		dmg.armor = memory.readword(dmg.armor_base)
		dmg.d_plus = memory.readbyte(dmg.armor_base + item_offset.plus)
		dmg.d_skill = memory.readbyte(address.groups + dmg.d_group + group_offset.skill)
		dmg.d_race = memory.readbyte(address.groups + dmg.d_group + group_offset.race)
		dmg.d_lead = memory.readbyte(address.groups + dmg.d_group + group_offset.formation)
	end)

	memory.registerexec(0x608a, function() --damage is about to be deducted
		if not dmg.attk_base then return end
		dmg.wounded = memory.readbyte(dmg.defender + char_offset.wounded)
		print()
		--print(string.format("armor_base: $%x\twounded: %02x", dmg.armor_base,dmg.wounded))
		print(string.format("attacker:\t$%x\t($%03x)\tlead: %02x\tskill: %d\tweapon:\t$%x %+d",
			dmg.attacker,dmg.a_group,dmg.a_lead,dmg.a_skill,dmg.weapon,dmg.a_plus))
		print(string.format("defendr:\t$%x\t($%03x)\tlead: %02x\tskill: %d\tarmor:\t$%x %+d",
			dmg.defender,dmg.d_group,dmg.d_lead,dmg.d_skill,dmg.armor,dmg.d_plus))
		dmg.modifier = memory.readwordsigned(address.damage_mod)
		dmg.final = AND(0xffff, memory.getregister("d7"))
		print(string.format("atkbase:\t$%x\tdmg: (%d%+d)*x + 1 = %d --> %d",
			dmg.attk_base,dmg.a_plus,dmg.modifier,dmg.a_plus+dmg.modifier+1,dmg.final))
		dmg = {}
	end)
	
	--[[
	local attacker_formation,defender_formation,attacker_base,defender_base
	memory.registerexec(0x5ff2, function() --about to compare formations
		attacker_base = memory.getregister("a1")
		defender_base = memory.getregister("a5")
		attacker_formation = memory.readbyte(attacker_base + group_offset.formation)
		defender_formation = memory.readbyte(defender_base + group_offset.formation)
		local attacker_upper = AND(0xf0, attacker_formation)
		local defender_upper = AND(0xf0, defender_formation)
	end)
	memory.registerexec(0x6010, function() --about to load formation modifier
		local modifier = memory.readword(0x013822 + memory.getregister("d6"))
		print(string.format("attacker formation: %02x\tdefender formation: %02x\tmodifier: %d",attacker_formation,defender_formation,modifier))
	end)]]
end

--------------------------------------------------------------------------------
--jewel_read requires rings/jewels to be added to inventory in this order
if mode.jewel_read then
	local jewel_read = {
		"R0 shield ring",
		"R1 normellon",
		"R2 sulandir",
		"R3 lit ring",
		"R4 nendil",
		"R5 gondrim",
		"J0 ruby star",
		"J1 diamond star",
		"J2 holy necklace",
		"J3 faith",
		"J4 emerald star",
		"J5 mal's gem",
		"J6 magicbane",
		"R6",
		"R7",
		"R8",
		"J7",
	}
	for k,v in ipairs(jewel_read) do
		memory.registerread(0xffc688 + 0xe*(k-1) + 0xc, function()
			if active then
				print(v)
			end
		end)
	end
end

--[[memory.registerexec(0x77DE, function() --force successful password check?
	local targetval = memory.readbyte(memory.getregister("a0"))
	memory.setregister("d1", targetval)
end)

local pc = 0x76c2
memory.registerexec(pc, function() --password check
	local d4 = memory.getregister("d4")
	print(string.format("pc $%04X\td4 $%08X",pc,d4))
end)]]

--[[local addr = 0xFFBA44 --rng
memory.register(addr,4,function(addr, size)
	if memory.readdword(addr) ~= 0x1f then
		memory.writedword(addr, 0x1f)
	end
end)]]

--------------------------------------------------------------------------------
local function autofire(period)
	if type(period) ~= "number" or period < 1 or not active or gens.framecount()%period*2 < period then
		return
	end
	if joypad.get()["A"] then
		joypad.set({A = false})
	end
	if joypad.get()["B"] then
		joypad.set({B = false})
	end
end

input.registerhotkey(3, function()
	if not mode.parley_travel then
		mode.parley_travel = 1
		gens.message("fight mode: forced parley")
	elseif mode.parley_travel == 1 then
		mode.parley_travel = 2
		gens.message("fight mode: forced travel")
	else
		mode.parley_travel = false
		gens.message("fight mode: normal")
	end
end)

local function parley_travel(val)
	if not val then
		return
	end
	memory.writebyte(address.fight_mode, val)
end

if mode.no_hostility then
	print("no hostility: on")
	for n = 0, 0x1e do --required for every group
		local addr = address.groups + group_offset.hostility + n*0x40
		memory.register(addr, 1, function(addr, size)
			local val = memory.readbyte(addr)
			if AND(val,0x01) == 1 then
				memory.writebyte(addr, AND(val,0xfe))
			end
		end)
	end
end

local function full_hp(go)
	if not go then
		return
	end
	local full = memory.readbyte(address.max_hp)
	for n = 0, nchars-1 do
		local char_base = address.char_base + char_offset.space * n
		if memory.readwordsigned(char_base + char_offset.group) == 0 then
			memory.writebyte(char_base + char_offset.hp, full)
		end
	end
end

if mode.infinite_GP then
	print("infinite gp: on")
end
local function infinite_GP(go)
	if not go then
		return
	end
	memory.writeword(address.groups + group_offset.GP, 20000)
end

local stages = {
	{crown = 0x0, 1,2,3,4,5,6,7,8,9,10,11,12,13},
	{crown = 0x0, 14,15,24,26,27,30},
	{crown = 0x0, 16,17,18,19,20,21,22,23},
	{crown = 0x0, 25,29,32,37,41,35},
	{crown = 0x0, 33,28,31,34,38,44,39},
	{crown = 0x3, 42,36,40,43,46},
	{crown = 0xf, 45,47,48,49,50,51},
}

if mode.stage_select then
	print("stage select: " .. (type(mode.stage_select) == "number" and mode.stage_select or "progressive"))
end
local function stage_select(stage)
	if not stage then
		return
	elseif type(stage) == "number" then
		--memory.writebyte(address.curr_stage, stage)
		memory.writebyte(address.dest_stage, stage)
	else
		mode.skip_crown = true
		memory.writebyte(address.dest_stage, current_stage + 1)
	end
end

local function skip_crown(go)
	if not go then
		return
	end
	local dest = memory.readbyte(address.dest_stage)
	for chapter,set in ipairs(stages) do
		for _,stage in ipairs(set) do
			if dest == stage then
				memory.writebyte(address.crown_pieces, set.crown)
				return
			end
		end
	end
end

--------------------------------------------------------------------------------
gui.register(function()
	HUD(mode.draw_HUD)
	memviewer(mode.draw_memviewer)
end)

local last_enemies,just_loaded_state = 100,true
savestate.registerload(function()
	just_loaded_state = true
end)

gens.registerbefore(function()
	active = memory.readbyte(address.active) == 0xff
	melee_id = memory.readbyte(address.inventory + attk_offset.space*1 + 1) * 11
	missile_id = memory.readbyte(address.inventory + attk_offset.space*2 + 1) * 11
	items_base = memory.readdword(address.items_ptr)
	current_stage = memory.readbyte(address.curr_stage)
	current_enemies = memory.readword(address.enemies)
	if active and not just_loaded_state and current_enemies > last_enemies then
		print("stage " .. current_stage .. ": enemy count increased by " .. current_enemies - last_enemies)
	end
	last_enemies,just_loaded_state = current_enemies,false

	autofire(mode.autofire)
	full_hp(mode.full_hp)
	infinite_GP(mode.infinite_GP)
	parley_travel(mode.parley_travel)
	skip_crown(mode.skip_crown)
	stage_select(mode.stage_select)
end)

if mode.skip_lag then
	print("skip lag: on")
	while true do
		gens.frameadvance()
		if gens.lagged() then
			gens.emulateframeinvisible()
		end
	end
end