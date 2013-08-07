-- Autostart
local awful = require("awful")
local naughty = require("naughty")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
local entries = {}
local autostart = {}

autostart.terminal = terminal or "urxvt"

function autostart.launch()
	for _,app in pairs(entries) do
		local l_app = app[1] or app
		local p_app = app[2] or l_app
		local apid = tonumber(awful.util.pread('bash -c "pgrep '.. p_app .. ' | tail -n 1"'));
		-- TODO: might be usefull
		--naughty.notify({timeout=0, text = l_app ..':'..p_app..':'..(apid or "x") })
		if not apid then
			if app.term ~= nil and app.term == true then
				l_app = autostart.terminal .. ' -name ' .. l_app .. ' -e '.. l_app
			end
		--	naughty.notify({ timeout=0,title = "START", text = l_app });
				awful.util.spawn(l_app)
		end
	end
end

function autostart.add(app)
	if type(app) == "table" then
		for _,ap in pairs(app) do
			table.insert(entries, ap)
		end	
	else
		table.insert(entries, app)
	end
end

return autostart