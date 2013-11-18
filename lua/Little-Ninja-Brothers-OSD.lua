local function realtime()
  gui.text(0x00,0x00,"killed "..memory.readbyte(0xb3).."/"..goal)
  local bossinv = memory.readbyte(0x6ef)
  if bossinv > 0 then gui.text(memory.readbyte(0x5fe),memory.readbyte(0x5fc)-0x10,bossinv) end
  local px,py,invtime,rockcurse,buncurse = {},{},{},{},{}
  for i=0,1 do
    px[i],py[i] = memory.readbyte(0x4d6+i*8),memory.readbyte(0x4d4+i*8)
    invtime[i] = memory.readbyte(0x122+i)
    if invtime[i] > 0 then gui.text(px[i],py[i],invtime[i]) end
    rockcurse[i] = memory.readbyte(0x124+i)
    if rockcurse[i] > 0 then gui.text(px[i],py[i],rockcurse[i]) end
    buncurse[i] = memory.readbyte(0x12a+i)
    if buncurse[i] > 0 then gui.text(px[i],py[i],buncurse[i]) end
  end
  for i=0,13 do
    local hp,id = memory.readbyte(0x593+i*0x8),memory.readbyte(0x590+i*0x8)
    local x,y = memory.readbyte(0x596+i*0x8),memory.readbyte(0x594+i*0x8)
    if hp > 0 and id > 0xf and id ~= 0x13 then gui.text(x,y,hp) end
    if id == 0xb then
      if memory.readbyte(0x591+i*0x8) == 0x83 then gui.drawbox(x-0x8, y+0x0, x+0x8, y-0x10,"red") end
      if memory.readbyte(0x592+i*0x8) == 0x02 then gui.text(x,y,"M") end
      if memory.readbyte(0x592+i*0x8) == 0x06 then gui.text(x,y,"X") end
    end
  end
end

local function turnbased()
  gui.text(0x70,0x08,"HP: "..memory.readbyte(0x87)*0x100 + memory.readbyte(0x84))
end

local function combatinfo()
  gui.text(0xc0,0x00,"maxlife "..memory.readbyte(0x434))
--  gui.drawpixel(0,0,"white")
  goal = memory.readbyte(0x4ac)
  if goal > 0 then realtime() end
  if memory.readbyte(0x47) == 0x4 then turnbased() end
end

gui.transparency(1)
gui.register(combatinfo)

while true do
  FCEU.frameadvance()
end