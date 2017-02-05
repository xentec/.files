local awesome = awesome
local screen = screen
local awful = require('awful')
local key = require('keys')
local beautiful = require('beautiful')

-- {{{ Rules
local rules = {
	-- Obligatory
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = key.client,
			screen = awful.screen.preferred,
			buttons = awful.util.table.join(
				awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
				awful.button({ modkey }, 1, awful.mouse.client.move),
				awful.button({ modkey }, 3, awful.mouse.client.resize)
			),
			placement = awful.placement.no_offscreen,
		}
	},
	-- #######################################
	{ rule = { class = "CaveStory+" },	properties = { floating = true } },
	{ rule = { class = "Steam" },		properties = { floating = true } },

	{ rule = { class = "pinentry" },	properties = { floating = true } },
	{ rule = { class = "gimp" },		properties = { floating = true } },
	-- Youtube Fullscreen
	{ rule = { instance = "exe" },		properties = { floating = true } },

--	{ rule_any = { class = { "Chromium", "Firefox" }},	properties = { switchtotag = true } },
	{ rule_any = { class = { "mplayer", "mplayer2", "mpv" }},
		properties = {
			floating = true,
			border_width = 0
		},
		placement = awful.placement.centered
	},
	{ rule = { instance = "novo" },
		properties = { floating = true, border_width = 0 },
		placement = awful.placement.top_right
	},

}
return rules
-- }}}
