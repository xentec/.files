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
    {
	    rule_any = {
	        instance = {
		        "DTA",  -- Firefox addon DownThemAll.
		        "copyq",  -- Includes session name in class.
		        "pinentry",
		        "exe", -- Youtube Fullscreen
	        },
	        class = {
	        	"Arandr",
	        	"Blueman-manager",
	        	"Gpick",
	        	"Kruler",
	        	"MessageWin",  -- kalarm.
	        	"Sxiv",
	        	"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
	        	"Wpa_gui",
	        	"veromix",
	        	"xtightvncviewer",

	        	"Steam",
	        	"CaveStory+",
	        	"gimp",
	        },

	        -- Note that the name property shown in xprop might be set slightly after creation of the client
	        -- and the name shown there might not match defined rules here.
	        name = {
	        	"Event Tester",  -- xev.
	        },
	        role = {
	        	"AlarmWindow",    -- Thunderbird's calendar.
	        	"ConfigManager",  -- Thunderbird's about:config.
	        	"pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
	        },
	    },
	    properties = { floating = true }
  	},
	-- #######################################
--	{ rule_any = { class = { "Chromium", "Firefox" }},	properties = { switchtotag = true } },
	{
		rule_any = { class = { "mplayer", "mplayer2", "mpv" }},
		properties = {
			floating = true,
			border_width = 0,
			placement = awful.placement.centered,
			screen = awful.screen.focused,
			callback = function(c)
     			c.screen = awful.screen.focused()
  			end
		},
	},
	{
		rule = { class = "Novo" },
		properties = {
			floating = true,
			border_width = 0,
			placement = awful.placement.top_right,
		},
	},

}
return rules
-- }}}
