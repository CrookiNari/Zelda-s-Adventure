local title_screen = {}

local fairy_img = sol.surface.create(*menus/fairy_cursor.png*)

function title_screen:on_draw(dst_surface)

fairy_img:draw(dst_surface, 32, 32)

end

return title_screen