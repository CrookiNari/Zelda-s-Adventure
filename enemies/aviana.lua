local enemy = ...

-- A crow that sleeps until the hero gets close.

local enemy = ...

function enemy:on_created()

  enemy:set_life(20)
  enemy:set_damage(0)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_hurt_style("boss")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_size(56, 56)
  enemy:set_origin(8, 13)

  enemy:set_obstacle_behavior("flying")

end

function enemy:on_restarted()

  local movement = sol.movement.create("random")
  movement:set_speed(64)
  movement:start(enemy)
end

