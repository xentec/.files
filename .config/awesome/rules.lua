local awful = require('awful')
local key = require('keys')
local beautiful = require('beautiful')
local screen = screen

-- {{{ Rules
local rules = {
	-- Obligatory
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			keys = key.client,
			buttons = awful.util.table.join(
				awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
				awful.button({ modkey }, 1, awful.mouse.client.move),
				awful.button({ modkey }, 3, awful.mouse.client.resize)
			)
		}
	},
	-- #######################################
	{ rule = { class = "CaveStory+" },	properties = { floating = true } },
	{ rule = { class = "Steam" },		properties = { floating = true } },
	{ rule = { instance = "gl" },		properties = { floating = true, border_width = 0 } },

	{ rule = { class = "pinentry" },	properties = { floating = true } },
	{ rule = { class = "gimp" },		properties = { floating = true } },
	-- Youtube Fullscreen
	{ rule = { instance = "exe" },		properties = { floating = true } },

	{ rule_any = { class = { "Chromium", "Firefox" }},	properties = { switchtotag = true } },
	{ rule_any = { class = { "mplayer", "mplayer2", "mpv" }},
		properties = {
			floating = true,
			border_width = 0
		},
		callback = function (c)
			local area = screen[c.screen].workarea
			local geometry = c:geometry()
			local bw = c.border_width * 2
			if geometry.width > area.width + bw then
				geometry.width =  area.width - bw
			end
			if geometry.height > area.height + bw then
				geometry.height =  area.height - bw
			end
			geometry.y = area.y + (area.height - geometry.height + bw) / 2
			geometry.x = area.x + (area.width - geometry.width + bw) / 2

			c:geometry(geometry)
		end
	},
}
return rules
-- }}}
