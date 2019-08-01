local enemy = ...

local behavior = require("enemies/lib/towards_hero")
local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 3,
  damage = 1,
  normal_speed = 32,
  faster_speed = 48,
  hurt_style = "monster",

}

behavior:create(enemy, properties)

