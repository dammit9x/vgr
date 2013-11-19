--[[lua script for fceu 0.98-28 or fceux
purpose: display enemy HP, bomb timers, hostage count, and body count for Snake's Revenge NES game
written by Dammit 7/24/2008; last edited 8/25/2008]]

local nudge = {}
  nudge.y = 0x18
  nudge.x = 0x08
local waitperiod = 3
local incontrol = waitperiod
local status = 0
local bodycount = 0
local underflow = 240
local bomb = {}
local enemy = {}
for i = 0, 4 do
  enemy[i] = {}
  enemy[i].hpold = 0
end

local function checkstatus()
  for i = 0, 4 do
    enemy[i].corpse = memory.readbyte(0x40c+0x1*i)
    enemy[i].y = memory.readbyte(0x47a+0x1*i)
    enemy[i].x = memory.readbyte(0x490+0x1*i)
    enemy[i].hpnew = memory.readbyte(0x5cd+0x1*i)
  end
  status = memory.readbyte(0x34)
end

local function hostagecount()
  local hostage = memory.readbyte(0x438)
  if hostage==204 or hostage==222 then
    local rescues = memory.readbyte(0x6e)
    gui.text(enemy[0].x-4*nudge.x,enemy[0].y-nudge.y,"HOSTAGES: "..rescues)
  end
end

local function bombtimer()
  bomb.laid = memory.readbyte(0x42d)
  bomb.x = memory.readbyte(0x485)
  bomb.y = memory.readbyte(0x46f)
  bomb.time = memory.readbyte(0x574)
-- draw bomb time only if there's a bomb
  if status==3 and bomb.laid==14 then gui.text(bomb.x,bomb.y,bomb.time) end
  if status==14 and bomb.laid==8 then gui.text(bomb.x,bomb.y,bomb.time) end
end

local function enemyhp()
  for i = 0, 4 do
-- draw HP only if the enemy is alive
    if enemy[i].corpse~=0 and enemy[i].hpnew>0 then
-- offset the drawn text, but only if it will stay in bounds
      if enemy[i].y>=nudge.y then enemy[i].y = enemy[i].y-nudge.y end
      if enemy[i].x>=nudge.y then enemy[i].x = enemy[i].x-nudge.x end
      gui.text(enemy[i].x,enemy[i].y,enemy[i].hpnew)
    end
  end
end

local function killcounter()
  for i = 0, 4 do
    if enemy[i].hpnew < 1 or enemy[i].hpnew > underflow then
      if enemy[i].hpold > 0 and enemy[i].hpold < underflow then
--inanimate objects don't count
        if enemy[i].corpse ~= 96 and enemy[i].corpse ~= 102 and enemy[i].corpse ~= 226 then
          bodycount = bodycount+1
        end
      end
    end
  end
end

local function drawdata()
  checkstatus()
--draw these only during the action
  if status==3 or status==14 then
    enemyhp()
    hostagecount()
    bombtimer()
  end
-- don't update kills during load screens
  if status == 2 or status == 13 or status == 18 then incontrol = 0 end
  if incontrol >= waitperiod then
    killcounter()
  else incontrol = incontrol+1 end
  gui.text(0,8,"BODY COUNT: "..bodycount)
  for i = 0, 4 do enemy[i].hpold = enemy[i].hpnew end
end

gui.transparency(1)
gui.register(drawdata)

while true do
  FCEU.frameadvance()
end