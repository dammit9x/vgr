--[[lua script for fceu 0.98-28 or fceux
purpose: display body count (kills) for River City Ransom NES game
written by Dammit 8/23/2008
Warning: not well tested]]

local bodycount = 0
local enemyalive = {}
for i = 0, maxenemies do
  enemyalive[i] = {}
  enemyalive[i].old = 0
end

local function killcounter()
  for i = 0, 1 do
    enemyalive[i].new = memory.readbyte(0x6c4+0x1*i)
    if enemyalive[i].new ~= enemyalive[i].old and enemyalive[i].new ~= 0 then
      bodycount = bodycount+1
    end
    enemyalive[i].old = enemyalive[i].new
  end
  gui.text(0,8,"BODY COUNT: "..bodycount)
end

gui.transparency(1)
gui.register(killcounter)

while true do
  FCEU.frameadvance()
end