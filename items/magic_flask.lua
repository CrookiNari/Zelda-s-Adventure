local item = ...

function item:on_created()

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_picked("magic_bar")
end

function item:on_obtaining(variant, savegame_variable)

  self:get_game():add_magic(4)
end