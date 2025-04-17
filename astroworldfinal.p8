pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- suni player
player = {
 x=64, y=100, w=8, h=8,
 thrusters=5, stars=0,
 lives=3,
 alive=true,
 sprite=1,
 win_state=nil,
 invincibility_timer=0
}

-- game state
game_state = "start"
welcome_sound_played = false

-- lists
obstacles = {}
stars = {}
hourglasses = {}

fall_speed = 1
slowmo_timer = 0
fall_distance = 0
target_distance = 2700
win_line_visible = false
game_tick = 0
hourglass_respawn_timer = 0

function _init()
 -- reset player & state
 player.x = 64
 player.y = 100
 player.thrusters = 5
 player.stars = 0
 player.lives = 3
 player.alive = true
 player.win_state = nil
 player.invincibility_timer = 0

 fall_speed = 1
 slowmo_timer = 0
 fall_distance = 0
 win_line_visible = false
 game_tick = 0
 hourglass_respawn_timer = 0

 obstacles = {}
 stars = {}
 hourglasses = {}

 for i=1,6 do spawn_star() end
 for i=1,5 do spawn_obstacle() end
 for i=1,1 do spawn_hourglass() end

 game_state = "start"
 welcome_sound_played = false
end

function spawn_star()
 add(stars, {x=flr(rnd(120)), y=flr(rnd(128)), w=8, h=8, sprite=3})
end

function spawn_obstacle()
 add(obstacles, {x=flr(rnd(120)), y=flr(rnd(128)), w=8, h=8, sprite=2})
end

function spawn_hourglass()
 add(hourglasses, {x=flr(rnd(120)), y=flr(rnd(128)), w=8, h=8, sprite=4})
end

function _update()
 -- start screen
 if game_state=="start" then
  if not welcome_sound_played then
   sfx(1)              -- welcome sound once
   welcome_sound_played=true
  end
  if btnp(4) then      -- z to start
   sfx(5)
   _init()
   game_state="play"
  end
  return
 end

 -- end screen after 1:30 (2700 frames)
 if game_tick > 2400 and not player.win_state then
  if player.stars >= 50 then
   player.y = 124
   player.alive = false
   player.win_state = "win"
  else
   player.alive = false
   player.win_state = "fail"
  end
 end

 -- after win/lose, go back to start
 if player.win_state and btnp(4) then
  _init()
  return
 end

 -- if player dead & out of lives, wait for z to restart
 if not player.alive and not player.win_state then
  if btnp(4) then _init() end
  return
 end

 game_tick += 1

 -- slow-mo effect
 if slowmo_timer>0 then
  slowmo_timer -=1
  fall_speed = 0.5
 else
  fall_speed = 1 + game_tick/600
 end

 -- simulate falling
 fall_distance += fall_speed
 if fall_distance>target_distance then
  win_line_visible=true
 end

 -- movement
 if btn(0) then player.x -=2 end
 if btn(1) then player.x +=2 end
 if btnp(5) and player.thrusters>0 then
  player.y -=12
  player.thrusters -=1
  sfx(6)
 end

 -- boundary clamp
 player.x = mid(0, player.x, 120)
 player.y = mid(0, player.y, 120)

 -- check win line
 if win_line_visible and player.y>122 then
  player.alive=false
  if player.stars>=50 then
   player.win_state="win"
  else
   player.win_state="fail"
  end
 end

 -- invincibility countdown
 if player.invincibility_timer>0 then
  player.invincibility_timer -=1
 end

 -- move objects
 move_objects(obstacles)
 move_objects(stars)
 move_objects(hourglasses)

 -- collisions & pickups
 check_collision(obstacles,"crash")
 check_pickups(stars, function()
  player.stars +=1
  sfx(0)             -- coin pickup sound
 end)

 -- hourglass logic
 for h in all(hourglasses) do
  if collides(player,h) then
   slowmo_timer=180
   sfx(3)           -- slow-mo activation sound
   del(hourglasses,h)
   hourglass_respawn_timer=600
  end
 end

 if hourglass_respawn_timer>0 then
  hourglass_respawn_timer -=1
 elseif #hourglasses<1 then
  spawn_hourglass()
 end
end

function move_objects(group)
 for o in all(group) do
  o.y -= fall_speed
  if o.y < -10 then
   o.y = 128 + rnd(20)
   o.x = rnd(120)
  end
 end
end

function check_collision(group,typ)
 for o in all(group) do
  if collides(player,o) and player.invincibility_timer==0 then
   player.lives -=1
   if player.lives>0 then
    sfx(4)         -- hit asteroid sound (first & second life)
    player.invincibility_timer=60
   else
    sfx(2)         -- out of lives sound
    player.alive=false
    player.win_state=typ
   end
  end
 end
end

function check_pickups(group,on_collect)
 for o in all(group) do
  if collides(player,o) then
   on_collect()
   o.y = 128 + rnd(30)
   o.x = rnd(120)
  end
 end
end

function get_zone()
 if game_tick < 750 then return "space" -- 0-25 seconds
 elseif game_tick < 1500 then return "atmosphere" -- 25-50 seconds
 else return "sky" -- 50-90 seconds
 end
end

function draw_background()
 if player.win_state == "win" then
  cls(6) -- light green ground for home scene
  rectfill(0, 90, 128, 128, 3) -- ground
  rectfill(40, 60, 88, 100, 8) -- house
  circfill(64, 40, 10, 9) -- sun
 else
  local z=get_zone()
  if z=="space" then
   cls(0)
   for i=1,20 do pset(rnd(128),rnd(128),7) end
  elseif z=="atmosphere" then
   cls(13); circfill(64,64,80,12)
  else
   cls(12); circfill(110,20,10,9)
  end
 end
end

function _draw()
 -- start screen
 if game_state=="start" then
  cls()
  print("hello! welcome to astroworld.",10,30,11)
  print("use arrow keys to move",25,45,7)
  print("press x to use thrusters",22,55,7)
  print("avoid obstacles",40,65,7)
  print("collect 50 stars to win",22,75,7)
  print("press z to begin!",35,95,10)
  return
 end

 draw_background()

 -- ui
 if not player.win_state then
  print("thrusters:"..player.thrusters,2,2,7)
  print("stars:"..player.stars.."/50",2,10,7)
  print("lives:"..player.lives,80,2,8)
  if slowmo_timer>0 then print("slow-mo",100,120,5) end
 end

 -- end screen
 if not player.alive and player.win_state then
  if player.win_state=="win" then
   print("you win!",40,50,11)
   print("our astronaut is home safe!",10,60,10)
  elseif player.win_state=="fail" then
   print("you ran out of time.",40,50,8)
   print("not enough stars collected.",10,60,8)
  end
 else
  if not player.alive then
   print("you died!",45,55,8)
  end
  print("press z to restart",30,80,7)
 end

 -- player sprite
 if player.invincibility_timer==0 or (player.invincibility_timer%6<3) then
  spr(player.sprite,player.x,player.y)
 end

 -- objects
 if not player.win_state then
  for o in all(obstacles) do spr(o.sprite,o.x,o.y) end
  for s in all(stars) do spr(s.sprite,s.x,s.y) end
  for h in all(hourglasses) do spr(h.sprite,h.x,h.y) end
 end

 -- win line
 if win_line_visible and not player.win_state then
  -- line removed
 else
  if not player.win_state then
   print("...keep falling...",30,120,5)
  end
 end
end

function collides(a,b)
 return not (a.x>b.x+b.w or b.x>a.x+a.w or a.y>b.y+b.h or b.y>a.y+a.h)
end

__gfx__
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007ceeeec7005555000000a000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007007e0ee0e7055555500000a000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770007eeeeee75555555500aaaaa0000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700077eeee77555555550000a000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000ee000055555500000a000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000eeeeee00055550000000000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e00ee00e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000000000054500f45000000000001b550000002e5500000000000375503c4500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000000000114501245013450164501a4501f4501d4501645015450174501b45020450264502b4502e4503145032450334502a45024450204501e4501d4501d4501c450184501845018450000000000000000
000a000000000000002425022250202501e2501c2501a25018250182501525013250112500e2500f2500b25009250062500325000250072500525004250032500325000000000000000000000000000000000000
001000001575015750157501575015750157501575015750157501575015750157501475014750147501475013750137501375013750137501375013750137501375013750137501375013750137501475014750
000100000000019150171501415012150111500e1500b150091500615005150021500115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003029270055001550035500355003550035500255001550015500155000550005500155002550035500455004550045500355003550025500255002550025500255004550045500355002550015500155001550
000100000000000000043500b35010350183502335028350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
