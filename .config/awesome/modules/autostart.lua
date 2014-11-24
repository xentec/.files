-- Autostart
local awful = require("awful")
local naughty = require("naughty")
local io = { popen = io.popen }

local entries = {}
local autostart = {}

autostart.terminal = "xterm"

function autostart.launch()
	local started = {}
	for _,app in pairs(entries) do
		local exec = app[1] or app
		local proc = app[2] or exec:match("([^%s.]+)%s*")

		--print(exec .. " -> ".. (exec:match("([^%s.]+)%s*") or 'nil'))
		--print('EXECUTING: bash -c "pgrep '.. proc .. ' | tail -n 1"')

		local pid = tonumber(awful.util.pread('bash -c "pgrep '.. proc .. ' | tail -n 1"'))

		if not pid then
			if app.term ~= nil and app.term == true then
				exec = autostart.terminal .. ' -name ' .. exec .. ' -e '.. exec
			end
			awful.util.spawn(exec)
			table.insert(started, exec)
		end
	end
	if #started > 0 then
		naughty.notify({ timeout = 5,
			text = '$ <span color="Lime">'.. table.concat(started,';\n   ') .. '</span>' });
	end
end

function autostart.add(app)
	if type(app) == "table" then
		for _,ap in pairs(app) do
			table.insert(entries,ap)
		end
	else
		table.insert(entries,app)
	end
end

function autostart.addDex()
	local f = io.popen("dex -a -e Awesome -d")
	for line in f:lines() do
		table.insert(entries, line:match("[^:]+: (.+)"))
    end
end

return autostart
