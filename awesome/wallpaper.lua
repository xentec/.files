local awful = require("awful")
local awful = require("awful")
if beautiful.wallpaper then
    for s = 1, screen.count() do
       gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

awful.util.spawn("nitrogen --restore")