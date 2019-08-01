local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local smoke_sprite
local beam_sprite
local angle = 0

local attacking = false
local can_throw_sword = true
local can_summon_hands = true
local can_surround_attack = true
local can_tide_attack = true
local can_pattern_attack = true
local can_projectile_a = true
local can_quake = true
local can_summon_helpers = true
local can_beam_attack = true
local can_melee_attack = true

local sweeping

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  smoke_sprite = enemy:create_sprite("enemies/ghost_smoke_large")
  enemy:bring_sprite_to_back(smoke_sprite)
  enemy:set_invincible_sprite(smoke_sprite)

  enemy:set_life(300)
  enemy:set_damage(25)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_hurt_style("boss")
end

function enemy:go_back_and_forth()
  local m = sol.movement.create("target")
  m:set_speed(50)
  m:start(enemy)
end

function enemy:go_back_and_forth_old()
  local movement = sol.movement.create("straight")
  movement:set_speed(70)
  movement:set_angle(angle)
  movement:start(enemy)
  function movement:on_obstacle_reached()
    angle = angle + math.pi
    enemy:go_back_and_forth()
  end
end

function enemy:on_restarted()
  enemy:go_back_and_forth()
  if sweeping then
    sweeping = false
    enemy:finish_attacking()
  end
  if enemy:get_sprite("sea_beam") then enemy:remove_sprite(enemy:get_sprite("sea_beam")) end
  sol.timer.start(enemy, 100, function()
    enemy:check_to_attack()
    return true
  end)
end


function enemy:finish_attacking()
  sol.timer.start(map, 900, function()
    attacking = false
    enemy:on_restarted()
  end)
end


--Select an Attack:
function enemy:check_to_attack()
  if not attacking then
    if can_throw_sword and enemy:get_distance(hero) < 136 then
      attacking = true
      can_throw_sword = false
      enemy:throw_sword()
      sol.timer.start(map, 10000, function() can_throw_sword = true end)

    elseif can_tide_attack and enemy:get_life() > game:get_value("sword_damage") then
      attacking = true
      can_tide_attack = false
      enemy:tide_attack()
      sol.timer.start(map, 15000, function() can_tide_attack = true end)

    elseif can_pattern_attack and enemy:get_life() > game:get_value("sword_damage") then
      attacking = true
      can_pattern_attack = false
      enemy:pattern_attack()
      sol.timer.start(map, 15000, function() can_pattern_attack = true end)

    elseif can_surround_attack and enemy:get_distance(hero) < 300 then
      attacking = true
      can_surround_attack = false
      enemy:surround_attack()
      sol.timer.start(map, 21000, function() can_surround_attack = true end)

    elseif can_projectile_a then
      attacking = true
      can_projectile_a = false
      enemy:projectile_a()
      sol.timer.start(map, 10000, function() can_projectile_a = true end)

    elseif can_summon_helpers then
      attacking = true
      can_summon_helpers = false
      enemy:summon_helpers()
      sol.timer.start(map, 10000, function() can_summon_helpers = true end)

    elseif can_beam_attack and enemy:get_life() > game:get_value("sword_damage") then
      attacking = true
      can_beam_attack = false
      enemy:beam_attack()
      sol.timer.start(map, 16000, function() can_beam_attack = true end)

    elseif can_melee_attack then
      attacking = true
      can_melee_attack = false
      enemy:melee_attack()
      sol.timer.start(map, 8000, function() can_melee_attack = true end)

    end

  end  
end


--Throw Sword
function enemy:throw_sword()
  local SPEED = 200
  local DISTANCE = 180
  sprite:set_animation("wind_up_sword")
  local m = sol.movement.create("straight")
  m:set_angle(hero:get_angle(enemy))
  m:set_speed(150)
  m:set_max_distance(120)
  m:start(enemy)
  sol.timer.start(map, 500, function()
    sprite:set_animation("attack", function()
      sprite:set_animation("walking")
    end)
    local x, y, layer = enemy:get_position()
    local boomerang = enemy:create_enemy({
      name = "enemy_thrown_boomerang",
      x = 0, y = 0, layer = layer, direction = 0, breed = "misc/enemy_weapon"
    })
    boomerang:set_damage(enemy:get_damage())
    boomerang:set_obstacle_behavior("flying")
    local sprite = boomerang:create_sprite("enemies/misc/spirit_sword")

    --sound
    sol.timer.start(enemy, 160, function()
      if enemy:get_map():has_entities("enemy_thrown_boomerang") then
        sol.audio.play_sound("boomerang")
        return true
      end
    end)

    local m2 = sol.movement.create("straight")
    m2:set_angle(enemy:get_angle(hero))
    m2:set_max_distance(DISTANCE)
    m2:set_speed(SPEED)
    m2:set_ignore_obstacles(true)
    m2:start(boomerang, function()
      sol.timer.start(map, 200, function()
        local m3 = sol.movement.create("target")
        m3:set_target(enemy)
        m3:set_ignore_obstacles(true)
        m3:set_speed(SPEED)
        m3:start(boomerang, function()
          boomerang:remove()
        end)
      end)
    end)

    function m2:on_obstacle_reached()
      sol.audio.play_sound("thunk1")
      boomerang:remove()
    end

    enemy:finish_attacking()

  end)
end


--Surround the hero with projectiles
function enemy:surround_attack()
  local fires = {}
  local NUM_PROJECTILES = 10
  local RADIUS = 112
  local DELAY = 1500
  local ZOOM_SPEED = 120

  sprite:set_animation("wind_up")
  sol.timer.start(map, 1000, function()
    sol.timer.start(enemy, 1000, function() sprite:set_animation("walking") end)
    sol.audio.play_sound("fire_burst_1")
    for i=1, NUM_PROJECTILES do
      fires[i] = enemy:create_enemy{breed = "misc/blue_fire"}
      local m = sol.movement.create("circle")
      m:set_center(hero)
      m:set_radius(RADIUS)
      m:set_angle_from_center(math.pi * 2 / NUM_PROJECTILES * i)
      m:set_angular_speed(2)
      m:set_ignore_obstacles()
      m:start(fires[i])
    end

    sol.timer.start(map, DELAY, function()
      sol.audio.play_sound("shoot_magic_2")
      for i=1, NUM_PROJECTILES do
        if fires[i] then
          local m = sol.movement.create("straight")
          m:set_speed(ZOOM_SPEED)
          m:set_angle(fires[i]:get_angle(hero))
          m:set_max_distance(fires[i]:get_distance(hero))
          m:set_ignore_obstacles()
          m:start(fires[i])
          function m:on_finished()
            fires[i]:remove()
          end
        end
      end
    end)

    enemy:finish_attacking()

  end)
end


--Sweeping projectile attack
function enemy:tide_attack()
    sweeping = true
    map:create_poof(enemy:get_position())
    sol.audio.play_sound("fire_burst_3")
    sprite:set_animation("invisible")
    smoke_sprite:set_animation("invisible")
    local x, y = enemy:get_position()
    local xref, yref = map:get_entity("boss_teleport_ref"):get_position()
    enemy:set_position(x, yref)
    local m = sol.movement.create("straight")
    local angle = math.random(1,2) * math.pi
    m:set_angle(angle)
    m:set_speed(250)
    m:start(enemy)
    function m:on_obstacle_reached()
      map:create_poof(enemy:get_position())
      sol.audio.play_sound("fire_burst_3")
      sprite:set_animation("wind_up_summon")
      smoke_sprite:set_animation("walking")
      m:set_angle(angle + math.pi)
      m:start(enemy)
      local breathing_fire = true
      sol.timer.start(enemy, 150, function()
        local fire = enemy:create_enemy{breed="misc/blue_fire"}
        local mf = sol.movement.create("straight")
        mf:set_angle(3*math.pi/2)
        mf:set_speed(150)
        mf:set_max_distance(250)
        mf:set_ignore_obstacles()
        mf:start(fire)
        sol.audio.play_sound("shoot_magic")
        function mf:on_obstacle_reached() fire:remove() end
        function mf:on_finished() fire:remove() end
        sol.timer.start(map, 3000, function() fire:remove() end)
        if breathing_fire then return true end
      end)

      function m:on_obstacle_reached()
        enemy:set_default_attack_consequences()
        breathing_fire = false
        sweeping = false
        enemy:finish_attacking()
      end
      function m:on_finished()
        enemy:set_default_attack_consequences()
        breathing_fire = false
        sweeping = false
        enemy:finish_attacking()
      end

    end
end


--Summon blasts in a pattern on the floor
function enemy:pattern_attack()
  enemy:stop_movement()
  local xref, yref, lref = map:get_entity("boss_teleport_ref"):get_position()
  map:create_poof(enemy:get_position())
  map:create_poof(xref, yref, lref)
  sol.audio.play_sound("fire_burst_3")
  sprite:set_animation("invisible")
  enemy:set_position(xref, yref, lref)
  sprite:set_animation("wind_up_summon")
  sol.audio.play_sound("charge_1")
  sol.timer.start(map, 1000, function()
    sol.timer.start(enemy, 1000, function() sprite:set_animation("walking") end)

    local NUM_IN_ROW = 6
    local X_SPACING = 48
    local function create_row(y)
      for i=1, NUM_IN_ROW do
        enemy:create_enemy{
          x = -NUM_IN_ROW * X_SPACING + (i-1) * X_SPACING + (NUM_IN_ROW / 2 * X_SPACING + X_SPACING - 8),
          y = y, breed = "misc/sea_blast"
        }
      end
    end

    for i=1, 3 do
      create_row(i*64 - 56)
    end
    sol.audio.play_sound("fire_burst_1")
    sol.timer.start(map, 1000, function() enemy:finish_attacking() end)
  end)
end


--Projectile A (I think there'll be more)
function enemy:projectile_a()
  local m = sol.movement.create("straight")
  m:set_speed(120)
  m:set_max_distance(96)
  m:set_angle(hero:get_angle(enemy))
  m:start(enemy)
  sprite:set_animation("wind_up")

  local function shoot()
    sol.audio.play_sound("shoot")
    local ball = enemy:create_enemy{breed="misc/energy_ball_black"}
    ball:go(enemy:get_angle(hero))
  end

  sol.timer.start(map, 1200, function()
    sol.timer.start(map, 2200, function() enemy:finish_attacking() end)
    sprite:set_animation("attack", function()
      shoot()
      sprite:set_animation("attack", function()
        shoot()
        sprite:set_animation("attack", function()
          shoot()
          sprite:set_animation("walking")
        end)
      end)
    end)
  end)
end


--Summon additional enemies
function enemy:summon_helpers()

  enemy:finish_attacking()
end


--Use hyper beam!
function enemy:beam_attack()
    sweeping = true
    map:create_poof(enemy:get_position())
    sol.audio.play_sound("fire_burst_3")
    sprite:set_animation("invisible")
    smoke_sprite:set_animation("invisible")
    local x, y = enemy:get_position()
    local xref, yref = map:get_entity("boss_teleport_ref"):get_position()
    enemy:set_position(x, yref)
    local m = sol.movement.create("straight")
    local angle = math.random(1,2) * math.pi
    m:set_angle(angle)
    m:set_speed(250)
    m:start(enemy)
    function m:on_obstacle_reached()
      map:create_poof(enemy:get_position())
      sol.audio.play_sound("fire_burst_3")
      sprite:set_animation("wind_up_summon")
      smoke_sprite:set_animation("walking")
      m:set_angle(angle + math.pi)
      m:set_speed(120)
      m:start(enemy)
      beam_sprite = enemy:create_sprite("enemies/misc/sea_beam", "beam_sprite")
      enemy:set_invincible_sprite(beam_sprite)
      --sound
      sol.audio.play_sound("sword_spin_attack_release")
      sol.timer.start(map, 1, function()
        sol.audio.play_sound("beam")
        if enemy:get_sprite("beam_sprite") then return 800 end
      end)

      function m:on_obstacle_reached()
        enemy:set_default_attack_consequences()
        sweeping = false
        enemy:finish_attacking()
        if enemy:get_sprite("beam_sprite") then enemy:remove_sprite(beam_sprite) end
      end

      --failsafe
      sol.timer.start(map, 3000, function()
        if sweeping then sweeping = false enemy:finish_attacking() end
        if enemy:get_sprite("beam_sprite") then enemy:remove_sprite(beam_sprite) end
      end)

    end
end


function enemy:melee_attack()
  sprite:set_animation("wind_up")
  sol.timer.start(map, 800, function()
    sprite:set_animation("attack", function() sprite:set_animation("walking") end)
    local sword_sprite = enemy:create_sprite("enemies/misc/sea_king_sword_slash")
    enemy:set_invincible_sprite(sword_sprite)
    sol.audio.play_sound("sword_spin_attack_release")
    enemy:finish_attacking()
  end)
end
