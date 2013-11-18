local version = "August 30, 2011"
local module = "sf2"
local textcolor = "yellow"

--regexp pattern: \[(".+")\] = {
--regexp replace: {type = \1, 

local profiles = {
--------------------------------------------------------------------------------
["sf2"] = {
	      {type = "vulnerability", color = 0x7777FF, fill = 0x40, outline = 0xFF},
	             {type = "attack", color = 0xFF0000, fill = 0x40, outline = 0xFF},
	{type = "proj. vulnerability", color = 0x00FFFF, fill = 0x40, outline = 0xFF},
	       {type = "proj. attack", color = 0xFF66FF, fill = 0x40, outline = 0xFF},
	               {type = "push", color = 0x00FF00, fill = 0x20, outline = 0xFF},
	               {type = "weak", color = 0xFFFF00, fill = 0x40, outline = 0xFF},
	              {type = "throw", color = 0xFFFF00, fill = 0x40, outline = 0xFF},
	          {type = "throwable", color = 0xF0F0F0, fill = 0x20, outline = 0xFF},
	      {type = "air throwable", color = 0x202020, fill = 0x20, outline = 0xFF},
},
--------------------------------------------------------------------------------
["marvel"] = {
	      {type = "vulnerability", color = 0x7777FF, fill = 0x20, outline = 0xFF},
	             {type = "attack", color = 0xFF0000, fill = 0x40, outline = 0xFF},
	{type = "proj. vulnerability", color = 0x00FFFF, fill = 0x40, outline = 0xFF},
	       {type = "proj. attack", color = 0xFF66FF, fill = 0x40, outline = 0xFF},
	               {type = "push", color = 0x00FF00, fill = 0x20, outline = 0xFF},
	    {type = "potential throw", color = 0xFFFF00, fill = 0x00, outline = 0x00}, --not visible by default
	       {type = "active throw", color = 0xFFFF00, fill = 0x80, outline = 0xFF},
	          {type = "throwable", color = 0xF0F0F0, fill = 0x20, outline = 0xFF},
},
--------------------------------------------------------------------------------
["cps2"] = {
	      {type = "vulnerability", color = 0x7777FF, fill = 0x40, outline = 0xFF},
	             {type = "attack", color = 0xFF0000, fill = 0x40, outline = 0xFF},
	{type = "proj. vulnerability", color = 0x00FFFF, fill = 0x40, outline = 0xFF},
	       {type = "proj. attack", color = 0xFF66FF, fill = 0x40, outline = 0xFF},
	               {type = "push", color = 0x00FF00, fill = 0x20, outline = 0xFF},
	           --{type = "tripwire", color = 0xFF66FF, fill = 0x40, outline = 0xFF}, --sfa3
	             --{type = "negate", color = 0xFFFF00, fill = 0x40, outline = 0xFF}, --dstlk, nwarr
	              {type = "throw", color = 0xFFFF00, fill = 0x40, outline = 0xFF},
	         {type = "axis throw", color = 0xFFAA00, fill = 0x40, outline = 0xFF}, --sfa, sfa2, nwarr
	          {type = "throwable", color = 0xF0F0F0, fill = 0x20, outline = 0xFF},
},
--------------------------------------------------------------------------------
["kof"] = {
	      {type = "vulnerability", color = 0x7777FF, fill = 0x40, outline = 0xFF},
	             {type = "attack", color = 0xFF0000, fill = 0x40, outline = 0xFF},
	{type = "proj. vulnerability", color = 0x00FFFF, fill = 0x40, outline = 0xFF},
	       {type = "proj. attack", color = 0xFF66FF, fill = 0x40, outline = 0xFF},
	               {type = "push", color = 0x00FF00, fill = 0x20, outline = 0xFF},
	              {type = "guard", color = 0xCCCCFF, fill = 0x40, outline = 0xFF},
	              {type = "throw", color = 0xFFFF00, fill = 0x40, outline = 0xFF},
	         {type = "axis throw", color = 0xFFAA00, fill = 0x40, outline = 0xFF}, --kof94, kof95
	          {type = "throwable", color = 0xF0F0F0, fill = 0x20, outline = 0xFF},
},
--------------------------------------------------------------------------------
["garou"] = {
	{type = "vulnerability", color = 0x7777FF, fill = 0x40, outline = 0xFF},
	       {type = "attack", color = 0xFF0000, fill = 0x40, outline = 0xFF},
	 {type = "proj. attack", color = 0xFF66FF, fill = 0x40, outline = 0xFF},
	         {type = "push", color = 0x00FF00, fill = 0x20, outline = 0xFF},
	        {type = "guard", color = 0xCCCCFF, fill = 0x40, outline = 0xFF},
	        {type = "throw", color = 0xFFFF00, fill = 0x40, outline = 0xFF},
	   {type = "axis throw", color = 0xFFAA00, fill = 0x40, outline = 0xFF},
},
--------------------------------------------------------------------------------
}

print("hitbox color demo, " .. version)
print("showing " .. module .. " module")

gui.register(function()
	local w, h = 0x20, 0x10
	local x, y = emu.screenwidth()/2, 0x28
	local dx, dy = 0x10, 0x04

	gui.text(8, 0, version, textcolor)
	for _, box in ipairs(profiles[module]) do
		gui.text(x - 4*20, y + h/2 - 4, string.format("0x%06X  0x%02X", box.color, box.fill), textcolor)
		gui.box(x - w/2, y, x + w/2, y + h, bit.lshift(box.color, 8) + box.fill, bit.lshift(box.color, 8) + box.outline)
		gui.text(x + 4*7, y + h/2 - 4, box.type, textcolor)
		y = y + h + dy
	end
end)
