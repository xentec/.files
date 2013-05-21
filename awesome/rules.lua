-- {{{ Rules
local rules = {
	{ rule = { class = "CaveStory+" },	properties = { floating = true } },
	{ rule = { class = "Steam" },		properties = { floating = true } },
	{ rule = { class = "MPlayer" },		properties = { floating = true } },
	{ rule = { class = "pinentry" },	properties = { floating = true } },
	{ rule = { class = "gimp" },		properties = { floating = true } },
	-- Youtube Fullscreen
	{ rule = { instance = "exe" },		properties = { floating = true } },
	-- Set Firefox to always map on tags number 2 of screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { tag = tags[1][2] } },
}
return rules
-- }}}