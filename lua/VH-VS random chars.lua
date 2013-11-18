--[[
Random character planning script for arcade Vampire Savior 1 / Vampire Hunter 2 / VS2
written by Dammit (dammit9x at hotmail dot com)
version 7/11/2010

Empirical data follows.
The initial "random" shadow character is at [0].
Shadow becomes the defeated opponent for the next match.
The opponents to be fought are determined by the initial character.
e is the extra match which can occur after stage 3, 4 or 5, or not at all.
Opponents ["e"] and [7] are irrelevant if there has been a VS match.
The number at right is the abundance of the initial character (the no. of times appearing).

When picking marionette (VH2/VS2 only) the opponent lineup will be one of the shadow lineups,
but with no sign of the [0] character. Marionette will not mirror the ["e"] character.
]]--

local fullset={
"ana", "aul", "bis", "bul", "dem", "don", 
"fel", "gal", "jed", "lei", "lil", "mor", 
"pho", "pyr", "qbe", "sas", "vic", "zab",
}

local lineup = {
	["vs1"]={
		{[0]="ana", "sas", "vic", "zab", e="qbe", "lei", "bul", "lil", "jed"}, --10
		{[0]="aul", "lei", "qbe", "lil", e="fel", "zab", "gal", "dem", "jed"}, -- 8
		{[0]="bis", "aul", "bul", "ana", e="vic", "dem", "lil", "mor", "jed"}, -- 4
		{[0]="bul", "ana", "aul", "mor", e="gal", "lil", "dem", "jed", "zab"}, --11
		{[0]="dem", "lil", "aul", "bul", e="bis", "ana", "lei", "jed", "mor"}, -- 8
		{[0]="fel", "zab", "qbe", "aul", e="mor", "bul", "gal", "jed", "lil"}, -- 8**
		{[0]="gal", "fel", "qbe", "vic", e="bul", "sas", "zab", "jed", "gal"}, -- 9
		{[0]="jed", "lil", "bul", "qbe", e="jed", "ana", "sas", "mor", "dem"}, --15
		{[0]="lei", "fel", "lil", "mor", e="zab", "qbe", "bul", "dem", "jed"}, -- 8***
		{[0]="lil", "dem", "qbe", "aul", e="jed", "zab", "fel", "lei", "mor"}, --11
		{[0]="mor", "bul", "ana", "aul", e="dem", "bis", "gal", "lei", "lil"}, -- 8
		{[0]="qbe", "fel", "sas", "vic", e="ana", "zab", "gal", "bul", "jed"}, --11
		{[0]="sas", "vic", "ana", "zab", e="aul", "qbe", "bis", "lei", "jed"}, -- 6
		{[0]="vic", "gal", "zab", "qbe", e="lil", "ana", "fel", "bul", "jed"}, -- 7
		{[0]="zab", "qbe", "vic", "sas", e="lei", "ana", "gal", "fel", "jed"}, --11
	},
	["vs2"]={
		{[0]="ana", "vic", "don", "pyr", e="qbe", "zab", "bis", "pho", "jed"}, -- 9
		{[0]="bis", "bul", "don", "dem", e="vic", "ana", "lil", "mor", "jed"}, -- 7
		{[0]="bul", "fel", "zab", "ana", e="don", "qbe", "lei", "pyr", "jed"}, -- 8
		{[0]="dem", "ana", "pho", "lil", e="bis", "lei", "pyr", "dem", "jed"}, --10
		{[0]="don", "ana", "pho", "dem", e="bul", "lei", "pyr", "vic", "jed"}, --13
		{[0]="fel", "zab", "qbe", "lei", e="mor", "bul", "pyr", "don", "jed"}, -- 6
		{[0]="jed", "don", "pho", "pyr", e="dem", "lil", "bul", "qbe", "jed"}, --16
		{[0]="lei", "don", "pho", "lil", e="zab", "qbe", "pyr", "ana", "jed"}, -- 9
		{[0]="lil", "pyr", "don", "qbe", e="mor", "zab", "bul", "fel", "jed"}, --10
		{[0]="mor", "qbe", "fel", "lil", e="dem", "dem", "don", "lei", "jed"}, -- 5
		{[0]="pho", "vic", "bis", "dem", e="fel", "lei", "don", "pyr", "jed"}, --10
		{[0]="pyr", "dem", "lei", "mor", e="pho", "bul", "lil", "bis", "jed"}, --10
		{[0]="qbe", "fel", "zab", "lil", e="ana", "don", "bul", "zab", "jed"}, -- 9
		{[0]="vic", "pho", "ana", "pho", e="lil", "bis", "don", "dem", "jed"}, -- 5
		{[0]="zab", "ana", "pho", "don", e="lei", "qbe", "bis", "lil", "jed"}, -- 8
	},
	["vh2"]={
		{[0]="ana", "vic", "don", "aul", e="sas", "lei", "bis", "pho", "pyr"}, --12
		{[0]="aul", "ana", "pho", "sas", e="fel", "lei", "don", "zab", "pyr"}, --12
		{[0]="bis", "don", "aul", "dem", e="vic", "ana", "lei", "ana", "pyr"}, -- 8
		{[0]="dem", "mor", "pho", "ana", e="bis", "lei", "don", "aul", "pyr"}, -- 8
		{[0]="don", "ana", "pho", "bis", e="dem", "aul", "sas", "vic", "pyr"}, --13
		{[0]="fel", "zab", "gal", "lei", e="mor", "aul", "dem", "don", "pyr"}, -- 5
		{[0]="gal", "fel", "zab", "ana", e="???", "aul", "lei", "don", "pyr"}, -- 7
		{[0]="lei", "don", "pho", "aul", e="zab", "gal", "sas", "ana", "pyr"}, --12
		{[0]="mor", "gal", "fel", "aul", e="dem", "zab", "don", "lei", "pyr"}, -- 4
		{[0]="pho", "vic", "bis", "dem", e="mor", "lei", "don", "sas", "pyr"}, -- 9**
		{[0]="pyr", "dem", "lei", "ana", e="don", "pho", "aul", "bis", "pyr"}, --15
		{[0]="sas", "don", "lei", "gal", e="aul", "zab", "ana", "fel", "pyr"}, -- 8
		{[0]="vic", "pho", "ana", "sas", e="gal", "bis", "aul", "dem", "pyr"}, -- 5***
		{[0]="zab", "ana", "pho", "don", e="lei", "sas", "bis", "gal", "pyr"}, -- 7
	},
	["sat"]={
		{[0]="dem", "lil", "aul", "bul", e="bis", "ana", "lei", "jed", "mor"}, --
		{[0]="jed", "lil", "bul", "qbe", e="jed", "ana", "sas", "mor", "dem"}, --
		{[0]="don", "ana", "gal", "dem", e="pho", "lei", "pyr", "vic", "jed"}, --
		{[0]="pho", "vic", "bis", "dem", e="pyr", "lei", "don", "bul", "jed"}, --
		{[0]="pyr", "dem", "lei", "mor", e="don", "bul", "lil", "bis", "jed"}, --
		{[0]="ana", "sas", "vic", "zab", e="qbe", "lei", "bul", "lil", "jed"}, --? assumed same as vs1
		{[0]="aul", "lei", "qbe", "lil", e="fel", "zab", "gal", "dem", "jed"}, --?
		{[0]="bis", "aul", "bul", "ana", e="vic", "dem", "lil", "mor", "jed"}, --?
		{[0]="bul", "ana", "aul", "mor", e="gal", "lil", "dem", "jed", "zab"}, --?
		{[0]="fel", "zab", "qbe", "aul", e="mor", "bul", "gal", "jed", "lil"}, --?
		{[0]="gal", "fel", "qbe", "vic", e="bul", "sas", "zab", "jed", "gal"}, --?
		{[0]="lei", "fel", "lil", "mor", e="zab", "qbe", "bul", "dem", "jed"}, --?
		{[0]="lil", "dem", "qbe", "aul", e="jed", "zab", "fel", "lei", "mor"}, --?
		{[0]="mor", "bul", "ana", "aul", e="dem", "bis", "gal", "lei", "lil"}, --?
		{[0]="qbe", "fel", "sas", "vic", e="ana", "zab", "gal", "bul", "jed"}, --?
		{[0]="sas", "vic", "ana", "zab", e="aul", "qbe", "bis", "lei", "jed"}, --?
		{[0]="vic", "gal", "zab", "qbe", e="lil", "ana", "fel", "bul", "jed"}, --?
		{[0]="zab", "qbe", "vic", "sas", e="lei", "ana", "gal", "fel", "jed"}, --?
	},
	["ps2"]={
		{[0]="don", "gal", "zab", "qbe", e="pho", "ana", "fel", "bul", "jed"}, -- 2 *diff from sat, same in ps1
		{[0]="pho", "ana", "aul", "mor", e="pyr", "lil", "dem", "jed", "zab"}, -- 2 *diff from sat, same in ps1
		{[0]="pyr", "lil", "aul", "bul", e="don", "ana", "lei", "jed", "mor"}, -- 2 *diff from sat, same in ps1
		{[0]="ana", "sas", "vic", "zab", e="qbe", "lei", "bul", "lil", "jed"}, --13
		{[0]="aul", "lei", "qbe", "lil", e="fel", "zab", "gal", "dem", "jed"}, --10
		{[0]="bis", "aul", "bul", "ana", e="vic", "dem", "lil", "mor", "jed"}, -- 4
		{[0]="bul", "ana", "aul", "mor", e="gal", "lil", "dem", "jed", "zab"}, --13
		{[0]="dem", "lil", "aul", "bul", e="bis", "ana", "lei", "jed", "mor"}, -- 9, same in ps1
		{[0]="fel", "zab", "qbe", "aul", e="mor", "bul", "gal", "jed", "lil"}, -- 9
		{[0]="gal", "fel", "qbe", "vic", e="bul", "sas", "zab", "jed", "gal"}, --10
		{[0]="jed", "lil", "bul", "qbe", e="jed", "ana", "sas", "mor", "dem"}, --18
		{[0]="lei", "fel", "lil", "mor", e="zab", "qbe", "bul", "dem", "jed"}, -- 9
		{[0]="lil", "dem", "qbe", "aul", e="jed", "zab", "fel", "lei", "mor"}, --13
		{[0]="mor", "bul", "ana", "aul", e="dem", "bis", "gal", "lei", "lil"}, --10
		{[0]="qbe", "fel", "sas", "vic", e="ana", "zab", "gal", "bul", "jed"}, --12
		{[0]="sas", "vic", "ana", "zab", e="aul", "qbe", "bis", "lei", "jed"}, -- 6
		{[0]="vic", "gal", "zab", "qbe", e="lil", "ana", "fel", "bul", "jed"}, -- 7
		{[0]="zab", "qbe", "vic", "sas", e="lei", "ana", "gal", "fel", "jed"}, --13
	},
}

local maximum = 1 --allowable number of missing chars
local checklist,backup,dupes,rerun

--function for backing up an array
local function copyarray(source,dest)
	for k,v in pairs(source) do
		dest[k]=v
	end
end

--create an array to track if we found all the characters
local function initializechars(g)
	checklist = {}
	if g then
		for k,v in ipairs(lineup[g]) do
			checklist[v[0]] = false
		end
	else
		for k,v in ipairs(fullset) do
			checklist[v] = false
		end
	end
end

--make and print a list of who's missing
local function checkchars(a,b,c,d)
	local missing,str = 0,""
	for k,v in pairs(checklist) do
		if v == false then
			str = str .. (missing==0 and "" or ", ") .. k
			missing = missing+1
		end
	end
	if missing<=maximum then
		print(missing.." missing from "..(c and d and a.." "..c.." + "..b.." "..d or a.." + "..b)..":\t"..str
			..(dupes>0 and " ("..rerun..")" or ""))
	end
end

--check off available characters only if not excluded (onegame)
local function process(profile,exclude)
	for k,char in pairs(profile) do
		local allowed=true
		for _,pos in ipairs(exclude) do
			if k==pos then allowed=false end
		end
		if allowed then checklist[char] = true end
	end
end

--find combinations that get all 14 or 15 chars in a single game with two playthroughs
local function onegame(excl_a,excl_b)
	str_a = excl_a[1].." & "..excl_a[2]
	str_b = excl_b[1].." & "..excl_b[2]
	dupes = 0
	for game,contents in pairs(lineup) do
		print(game..", excluding "..str_a.." from lineup 1, and "..str_b.." from lineup 2:")
		for _,profile_a in ipairs(lineup[game]) do
			initializechars(game)
			process(profile_a,excl_a)
			backup = {}
			copyarray(checklist,backup)
			for _,profile_b in ipairs(lineup[game]) do
				if profile_a~=profile_b then
					process(profile_b,excl_b)
					checkchars(profile_a[0],profile_b[0])
					copyarray(backup,checklist)
				end
			end
		end
		print()
	end
end

--find combinations that get all 18 chars in two games with one playthrough each
local function twogames(game_a,game_b)
	print("Combinations between "..game_a.." and "..game_b..":")
	for a,profile_a in ipairs(lineup[game_a]) do
		initializechars()
		for j,char_a in pairs(profile_a) do
			checklist[char_a] = true
		end
		backup = {}
		copyarray(checklist,backup)
		for b,profile_b in ipairs(lineup[game_b]) do
			dupes,rerun = 0,""
			for k,char_b in pairs(profile_b) do
				if checklist[char_b] then
					rerun = rerun .. (dupes==0 and "" or ", ") .. char_b
					dupes = dupes+1
				else
					checklist[char_b] = true
				end
			end
			checkchars(game_a,game_b,profile_a[0],profile_b[0])
			copyarray(backup,checklist)
		end
	end
	print()
end

print("max exclusions: "..maximum)
print("() = duplicates")
print()

onegame({6,7},{"e",7})
onegame({"e",7},{"e",7})

twogames("vs1","vs2")
twogames("vs1","vh2")
twogames("vs2","vh2")
twogames("sat","sat")
twogames("ps2","ps2")
