-- Autostart
local awful = require("awful")
local naughty = require("naughty")
local io = { popen = io.popen }

local entries = {}
local autostart = {}

autostart.terminal = "xterm"

function autostart.launch()
	local started = {}
	for exec,app in pairs(entries) do
		local proc = app[2] or exec:match("([^%s.]+)%s*")

		--naughty.notify({ timeout = 0,
			--text = (type(app) == "table" and "T:"..app[1] or "S:"..tostring(app)).." > "..(type(proc) == "table" and "T:"..proc[1] or "S:"..tostring(proc))});

		local count = tonumber(awful.util.pread('pgrep -cf '.. proc))

		if count == 0 then
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
			entries[ap[1] or ap] = ap
		end
	else
		entries[app] = app
	end
end

function autostart.addXDG()
	local f = io.popen("dex -d -a -e Awesome")
	local exec
	for line in f:lines() do
		exec = line:match("[^:]+: (.+)")
		if entries[exec] == nil then
			entries[exec] = exec
		end
    end
end

return autostart
