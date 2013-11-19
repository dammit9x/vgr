local default_address = 0x100000
local default_address = 0x10FE36

local custom_addresses = {
	[0x10E000] = {"garoup"},
	--[0x10FFF6] = {"garou"},
}

local debug_dipswitch = {
	[1] = {setting = "00000011", apply = true},
	[2] = {setting = "00000000", apply = true},
	[3] = {setting = "00000000", apply = true},
	[4] = {setting = "00000000", apply = true},
	[5] = {setting = "00000000", apply = true},
	[6] = {setting = "00000000", apply = true},
}

local function get_base_address()
	if emu.sourcename() ~= "neodrvr.c" and emu.sourcename() ~= "neogeo" then
		error("This script is for NeoGeo games.", 0)
	end
	for address, game_list in pairs(custom_addresses) do
		for _, game in ipairs(game_list) do
			if emu.parentname() == game or emu.romname() == game then
				print(string.format("Custom address %06X for game %s", address, game))
				print()
				return address
			end
		end
	end
	return default_address
end

local function get_hex_val(n, bank)
	if type(bank.setting) ~= "string" or bank.setting:len() < 8 then
		error("The setting of bank " .. n .. " is '" .. tostring(bank.setting) .. "'. It should be a quoted string of 8 numbers.", 0)
	end
	bank.hex_val = 0
	for bit_number = 1, 8 do
		if tonumber(bank.setting:sub(bit_number, bit_number)) > 0 then
			bank.hex_val = bank.hex_val + bit.lshift(1, bit_number-1)
		end
	end
end

local base_address = get_base_address()
for n, bank in ipairs(debug_dipswitch) do
	bank.address = base_address + n-1
	if not bank.hex_val then
		get_hex_val(n, bank)
	end
end

print("bank\taddress\t\tbinary\t\thex\tapplied")
for n, bank in ipairs(debug_dipswitch) do
	print(string.format("%d\t0x%06X\t%s\t0x%02X\t%s", n, bank.address, bank.setting, bank.hex_val, bank.apply and "y" or "n"))
	memory.writebyte(bank.address, bank.hex_val)
end