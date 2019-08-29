-- Lua script of map Plain of Andor/aj22.
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
function hungrylady:on_interaction()

game:start_dialog("hungrylady.dialog1", function(answer)
  if answer == 2 then -- No.
  game:start_dialog("hungrylady.no")
  else 
  game:start_dialog("hungrylady.yes")
  end
end)

function hungrygirl:on_interaction()

game:start_dialog("hungrylady.child")
end

function hungryboy:on_interaction()

game:start_dialog("hungrylady.child")
end

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

-- Stuff to finish:
-- complete hungry lady quest