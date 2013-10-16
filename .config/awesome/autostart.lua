-- Autostart
local awful = require("awful")
local naughty = require("naughty")

local entries = {}
local autostart = {}

autostart.terminal = terminal or "urxvt"

function autostart.launch()
	for _,app in pairs(entries) do
		local exec = app[1] or app
		local proc = app[2] or exec:match("([^%s.]+)%s*")

		--print(exec .. " -> ".. (exec:match("([^%s.]+)%s*") or 'nil'))
		--print('EXECTING: bash -c "pgrep '.. proc .. ' | tail -n 1"')

		local pid = tonumber(awful.util.pread('bash -c "pgrep '.. proc .. ' | tail -n 1"'))

		if not pid then
			if app.term ~= nil and app.term == true then
				exec = autostart.terminal .. ' -name ' .. exec .. ' -e '.. exec
			end
			awful.util.spawn(exec)
			naughty.notify({ timeout = 5, title = 'AutoStart', text = '$ <span color="Lime">'.. exec .. '</span>' });
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