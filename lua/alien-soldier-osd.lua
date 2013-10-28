--lua script for gens rerecording+lua: http://code.google.com/p/gens-rerecording/
--purpose: display HP and weapon info on-screen and remove cursor flickering for the Alien Soldier game
--written on 5/10/2009; last edited 8/13/2009 (dammit9x at hotmail dot com)

local address = {xposition=0xff8652, yposition=0xff824a, ammocur=0xffa260, ammomax=0xffa268, 
  regenwait=0xffa258, selected=0xffa24f, cooldown=0xff8239, playercur=0xff820a, playermax=0xffa218,
  playerinv=0xffa45f,bosscur=0xff8200, bossvuln=0xff80c6}
local draw = {xammo=0xe0, yammo=0x00, inc=0x18, xplayer=0x30, yplayer=0x08}
local status = {notfull="white", full="green", regen="blue", vuln="white", invuln="yellow"}
local showinhex = false

gui.register( function ()
  if memory.readword(address.xposition) ~= 0 then
    
    local selected = memory.readbyte(address.selected)/2
    gui.drawbox(draw.xammo+draw.inc*selected+1, draw.yammo+9, draw.xammo+draw.inc*selected+13, draw.yammo+21)
    
    local textwidth = 0
    for n = 0,3 do
      local ammocur = memory.readword(address.ammocur+2*n)
      local ammomax = memory.readword(address.ammomax+2*n)
      local regenwait = memory.readword(address.regenwait+2*n)
      local color = status.notfull
      if ammocur == ammomax then color = status.full
      elseif regenwait <= 5 and n ~= selected then color = status.regen
      end
      gui.text(draw.xammo+draw.inc*n, draw.yammo, ammocur, color)
      if n == selected then
        gui.text(draw.xplayer,draw.yplayer+0x8,ammocur.."/"..ammomax,color)
        textwidth = 4*string.len(string.format(ammocur.."/"..ammomax))
      end
    end
    local cooldown = memory.readbyte(address.cooldown)
    if cooldown < 0xff then
      gui.text(draw.xplayer+textwidth,draw.yplayer+0x8,"("..cooldown..")",status.invuln)
    end
  
    local playercur = memory.readword(address.playercur)
    local playermax = memory.readword(address.playermax)
    local playerinv = memory.readbyte(address.playerinv)
    local color = status.notfull
    if playercur == playermax then color = status.full end
    gui.text(draw.xplayer,draw.yplayer,playercur.."/"..playermax,color)
    textwidth = 4*string.len(string.format(playercur.."/"..playermax))
    if playerinv < 0xff then
      gui.text(draw.xplayer+textwidth,draw.yplayer,"("..playerinv..")",status.invuln)
    end
    
    local bosscur = memory.readword(address.bosscur)
    local bossvuln = memory.readbyte(address.bossvuln)
    if bosscur > 0 or bossvuln == 0xff then
      local color = status.invuln
      if bossvuln == 0xff then color = status.vuln end
      if showinhex then
        gui.text(draw.xplayer,draw.yplayer+0x10,"0x"..string.format("%X",bosscur),color)
      else
        gui.text(draw.xplayer,draw.yplayer+0x10,bosscur,color)
      end
    end
    
  end
end)
