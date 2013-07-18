local awful = require('awful')
local key = require('keys')
local beautiful = require('beautiful')

-- {{{ Rules
local rules = {
	-- Obligatory
	{ rule = { },	properties = {
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
	{ rule = { class = "Chromium" },	properties = { switchtotag = true } },
	{ rule = { class = "CaveStory+" },	properties = { floating = true } },
	{ rule = { class = "Steam" },		properties = { floating = true } },
	{ rule = { class = "MPlayer" },		properties = { floating = true } },
	{ rule = { class = "pinentry" },	properties = { floating = true } },
	{ rule = { class = "gimp" },		properties = { floating = true } },
	-- Youtube Fullscreen
	{ rule = { instance = "exe" },		properties = { floating = true } },
}
return rules
-- }}}