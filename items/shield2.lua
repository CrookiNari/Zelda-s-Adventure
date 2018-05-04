local item = ...

function item:on_created()

  self:set_savegame_variable("possession_shield2")
  self:set_sound_when_picked(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the shield determines the built-in ability "shield2".
  self:get_game():set_ability("shield2", variant)
end
