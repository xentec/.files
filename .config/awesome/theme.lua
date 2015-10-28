---------------------------
-- Default awesome theme --
---------------------------

theme = {}

--theme.font          = "cantarell 9"

theme.font_name 	= "Bitstream Vera Sans"
theme.font_size		= 10
theme.font_mono		= "Source Code Pro" 
theme.font_icon		= "Font Awesome"
theme.font 			= theme.font_name .. " " .. tostring(theme.font_size)

theme.bg_bg         = "#44444400"
theme.bg_normal     = "#444444AA"
theme.bg_focus      = "#444444DD"
theme.bg_urgent     = "#ff0000FF"
theme.bg_minimize   = "#44444488"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#888888"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap   = 4
theme.border_width  = 4
theme.border_normal = "#44444488"
theme.border_focus  = "#444444AA"
theme.border_marked = "#444444DD"

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
theme.awesome_icons = "/usr/share/awesome/themes/default/layouts/"
theme.layout_fairh      = theme.awesome_icons .. "fairhw.png"
theme.layout_fairv      = theme.awesome_icons .. "fairvw.png"
theme.layout_floating   = theme.awesome_icons .. "floatingw.png"
theme.layout_magnifier  = theme.awesome_icons .. "magnifierw.png"
theme.layout_max        = theme.awesome_icons .. "maxw.png"
theme.layout_fullscreen = theme.awesome_icons .. "fullscreenw.png"
theme.layout_tilebottom = theme.awesome_icons .. "tilebottomw.png"
theme.layout_tileleft   = theme.awesome_icons .. "tileleftw.png"
theme.layout_tile       = theme.awesome_icons .. "tilew.png"
theme.layout_tiletop    = theme.awesome_icons .. "tiletopw.png"
theme.layout_spiral     = theme.awesome_icons .. "spiralw.png"
theme.layout_dwindle    = theme.awesome_icons .. "dwindlew.png"
theme.layout_cornernw   = theme.awesome_icons .. "cornernww.png"
theme.layout_cornerne   = theme.awesome_icons .. "cornernew.png"
theme.layout_cornersw   = theme.awesome_icons .. "cornersww.png"
theme.layout_cornerse   = theme.awesome_icons .. "cornersew.png"

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
