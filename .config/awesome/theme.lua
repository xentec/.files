---------------------------
-- Default awesome theme --
---------------------------

theme = {}

--theme.font          = "cantarell 9"

theme.font_name 	= "Bitstream Vera Sans"
theme.font_size		= 10
theme.font 			= theme.font_name .. " " .. tostring(theme.font_size)
theme.font_mono		= "Source Code Pro" 
theme.font_icon		= "Font Awesome"

theme.bg_bg         = "#22222200"
theme.bg_normal     = "#222222AA"
theme.bg_focus      = "#535d6cFF"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444AA"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = 4
theme.border_normal = "#000000"
theme.border_focus  = "#535d6c"
theme.border_marked = "#91231c"

theme.taglist_bg_occupied = "#444444"
theme.tooltip_opacity = 1

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- theme.wallpaper = "/usr/share/awesome/themes/default/background.png"

-- You can use your own layout icons like this:
local aPath = "/usr/share/awesome/themes/default/layouts/"

theme.layout_fairh = aPath .. "fairhw.png"
theme.layout_fairv = aPath .. "fairvw.png"
theme.layout_floating  = aPath .. "floatingw.png"
theme.layout_magnifier = aPath .. "magnifierw.png"
theme.layout_max = aPath .. "maxw.png"
theme.layout_fullscreen = aPath .. "fullscreenw.png"
theme.layout_tilebottom = aPath .. "tilebottomw.png"
theme.layout_tileleft   = aPath .. "tileleftw.png"
theme.layout_tile = aPath .. "tilew.png"
theme.layout_tiletop = aPath .. "tiletopw.png"
theme.layout_spiral  = aPath .. "spiralw.png"
theme.layout_dwindle = aPath .. "dwindlew.png"

theme.lain_icons         = "/usr/share/awesome/lib/lain/icons/layout/default/"
theme.layout_termfair    = theme.lain_icons .. "termfairw.png"
theme.layout_centerfair  = theme.lain_icons .. "centerfairw.png"
theme.layout_cascade     = theme.lain_icons .. "cascadew.png"
theme.layout_cascadetile = theme.lain_icons .. "cascadebrowsew.png"
theme.layout_centerwork  = theme.lain_icons .. "centerworkw.png"

theme.layout_uselesstile = theme.layout_tile
theme.layout_uselessfair = theme.layout_termfair

theme.useless_gap_width = 10

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme
