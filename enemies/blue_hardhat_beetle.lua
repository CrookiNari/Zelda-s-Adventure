local enemy = ...

-- Blue Hardhat Beetle.

local behavior = require("enemies/lib/towards_hero")
local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 5,
  damage = 1,
  normal_speed = 32,
  faster_speed = 48,
  hurt_style = "monster",
  push_hero_on_sword = true,
}

behavior:create(enemy, properties)

