-- Autostart
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")

local entries = {}
local autostart = {}

autostart.terminal = "xterm"


local function start(exec, check, term)
	awful.spawn.easy_async('pgrep -cf '.. check,
		function (stdout, stderr)
			if tonumber(stdout) ~= 0 then
				return
			end

			if term then
				exec = autostart.terminal .. ' -name ' .. exec .. ' -e '.. exec
			end
			awful.spawn.spawn(exec)
			naughty.notify({ timeout = 5, text = '$ <span color="Lime">'.. exec .. '</span>' });
		end)
end

function autostart.launch()
	awful.spawn.easy_async("dex -d -a -e Awesome",
		function(stdout, stderr, _, exists)
			local exec
			for line in stdout:gmatch("[^\r\n]+")
			do
				exec = line:match("[^:]+: (.+)")
				start(exec, exec:match("([^%s.]+)%s*"))
			end
		end)

	for exec,app in pairs(entries) do
		local proc = app[2] or exec:match("([^%s.]+)%s*")
		--naughty.notify({ timeout = 0,
			--text = (type(app) == "table" and "T:"..app[1] or "S:"..tostring(app)).." > "..(type(proc) == "table" and "T:"..proc[1] or "S:"..tostring(proc))});

		start(exec, proc, app.term)
	end
end

function autostart.add(app)
	if type(app) == "table" then
		for _,ap in pairs(app) do
			entries[ap[1] or ap] = ap
		end
	else
		entries[app] = {}
	end
end

function autostart.addXDG()

end

return autostart
