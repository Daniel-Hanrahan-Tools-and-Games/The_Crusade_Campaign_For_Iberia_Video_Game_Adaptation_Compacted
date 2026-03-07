-- title: The_Crusade_Campaign_For_Iberia_Compacted
-- author: Daniel Hanrahan Tools and Games
-- license: GNU GPL-3.0
-- version: 1
-- script: lua

-- =====================
-- RNG / DICE
-- =====================
function D4()  return math.random(1,4)  end
function D6()  return math.random(1,6)  end
function D8()  return math.random(1,8)  end
function D10() return math.random(1,10) end
function D12() return math.random(1,12) end
function D20() return math.random(1,20) end

rng_seeded = false -- flag to seed RNG once

-- =====================
-- GAME STATE
-- =====================
STATE_NOTICE   = 0
STATE_MENU     = 1
STATE_RESOLVE  = 2
STATE_GAMEOVER = 3

state  = STATE_NOTICE
cursor = 1
log    = {}

-- cities table
cities = {
 "Almeria","Pampalona","Zargosa","Porto","Barcelona",
 "Toledo","Coimbra","Santarem","Lisbon","Faro",
 "Cordoba","Seville","Grenada","Balearic Islands"
}

function add_log(t)
 table.insert(log, t)
 if #log > 10 then table.remove(log, 1) end
end

-- =====================
-- NOTICE SCREEN
-- =====================
function draw_notice()
 cls(0)
 print("Copyright (C) 2025 Daniel",0,10,12,false,1,true)
 print("Hanrahan Tools and Games",0,20,12,false,1,true)
 print("SPDX-License-Identifier: GPL-3.0-or-later",0,30,12,false,1,true)
 print("A copy of the GNU General Public License is",0,40,12,false,1,true)
 print("included in the file COPYING; if not, see",0,50,12,false,1,true)
 print("<https://www.gnu.org/licenses/>.",0,60,12,false,1,true)
 print("Information just about the stuff in this",0,70,12,false,1,true)
 print("software not covered by the GNU General",0,80,12,false,1,true)
 print("Public License version 3: This work is",0,90,12,false,1,true)
 print("licensed under Attribution-ShareAlike",0,100,12,false,1,true)
 print("4.0 International",0,110,12,false,1,true)
 print("PRESS Z TO START",80,120,12,false,1,true)
 if btnp(4) then state = STATE_MENU end
end

-- =====================
-- MENU INPUT
-- =====================
function handle_menu_input()
 if btnp(0) then cursor = math.max(1, cursor-1) end
 if btnp(1) then cursor = math.min(#cities, cursor+1) end
 if btnp(4) then
  add_log("Targeting "..cities[cursor])
  state = STATE_RESOLVE
 end
end

-- =====================
-- GAME LOGIC
-- =====================
function resolve_conquest()
 add_log("Army splits and advances via all routes...")

 local d4  = D4()
 local d6  = D6()
 local d8  = D8()
 local d10 = D10()
 local d12 = D12()
 local d20 = D20()

 -- Terrain traversal
 if d12 == 12 then add_log("Lost crossing enemy rivers/seas."); state = STATE_GAMEOVER; return end
 add_log("Traversed enemy rivers and seas successfully.")
 if d10 == 10 then add_log("Lost in deserts."); state = STATE_GAMEOVER; return end
 add_log("Traversed deserts successfully.")
 if d8 == 8 then add_log("Lost crossing allied rivers."); state = STATE_GAMEOVER; return end
 add_log("Traversed allied rivers successfully.")
 if d6 == 6 then add_log("Lost in forests."); state = STATE_GAMEOVER; return end
 add_log("Traversed forests successfully.")
 if d4 == 4 then add_log("Lost in mountains."); state = STATE_GAMEOVER; return end
 add_log("Traversed mountains successfully.")
 if d20 ~= 20 then add_log("Army lost before final assault."); state = STATE_GAMEOVER; return end
 add_log("City conquered successfully!")

 -- Political crisis (same dice)
 if d12 == 12 then add_log("New government forms."); state = STATE_GAMEOVER; return end
 add_log("No new government.")
 if d10 == 10 then add_log("Civil war erupts."); state = STATE_GAMEOVER; return end
 add_log("No civil war.")
 if d8 == 8 then add_log("Annexation succession crisis."); state = STATE_GAMEOVER; return end
 add_log("No annexation succession crisis.")
 if d6 == 6 then add_log("Breakaway succession crisis."); state = STATE_GAMEOVER; return end
 add_log("No breakaway succession crisis.")
 if d4 == 4 then add_log("Marriage annexation."); state = STATE_GAMEOVER; return end
 add_log("No marriage annexation.")
 if d20 == 20 then add_log("Political revolution breakaway."); state = STATE_GAMEOVER; return end
 add_log("No political revolution breakaway.")

 add_log("Campaign continues.")
 state = STATE_MENU
end

-- =====================
-- DRAWING
-- =====================
-- the menu to choose what cities to conquer
function draw_menu()
 print("Choose a city to conquer:",5,5,15)
 for i=1,#cities do
  local y = 12 + i*8
  if i == cursor then
   print("> "..cities[i],5,y,14)
  else
   print("  "..cities[i],5,y,12)
  end
 end
end
-- what happens after attempted conquest
function draw_log()
 for i=1,#log do
  print(log[i],5,20 + i*6,11) -- shifted down to start closer to top
 end
end

function draw_gameover()
 print("GAME OVER",5,5,8) -- top-left corner
 print("Press X to restart",5,15,12)
 if btnp(5) then
  log = {}
  cursor = 1
  state = STATE_MENU
 end
end

-- =====================
-- MAIN LOOP
-- =====================
function TIC()
 if not rng_seeded then
  math.randomseed(math.floor(time()))
  rng_seeded = true
 end

 cls()
 if state == STATE_NOTICE then
  draw_notice()
 elseif state == STATE_MENU then
  handle_menu_input()
  draw_menu()
  draw_log()
 elseif state == STATE_RESOLVE then
  resolve_conquest()
 elseif state == STATE_GAMEOVER then
  draw_gameover()
  draw_log()
 end
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

