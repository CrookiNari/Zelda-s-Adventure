-- Lua script of map Vision Henge/visionhenge5.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
end
  -- You can initialize the movement and sprites of various
  -- map entities here.
function lady:on_interaction()

game:start_dialog ("sample_text", function(answer)
  if answer == 3 then -- Yes.
  game:start_dialog("sample_text2")
  else 
  game:start_dialog("sample_text3")

end)

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
