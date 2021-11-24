-- Autostart
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")

local entries = {}
local autostart = {}

autostart.terminal = "xterm"

local function spawn(args)
	local args = args or {}
	local exec = args.exec
	if args.term then
		exec = autostart.terminal .. ' -name ' .. args.exec .. ' -e '.. exec
	end
	awful.spawn.spawn(exec)
	naughty.notify({ timeout = 5, text = '$ <span color="Lime">'.. exec .. '</span>' })
end

local function spawn_checked(args)
	if not args then return end
	if not args.check then args.check = args.exec:match("([^%s.]+)%s*") end
	if args.force or not args.check then return spawn(args) end

	local check = string.gsub(args.check, "(.*%s)(.*)", "%2") -- cmd line
	check = string.gsub(check, "(.*/)(.*)", "%2") -- base name
	check = string.gsub(check, "(.*)%s", "%1") -- binary w/ args
	awful.spawn.easy_async('pgrep -c '.. check,
		function (stdout, stderr)
			if tonumber(stdout) ~= 0 then
				return
			end
			spawn(args)
		end)
end

function autostart.launch()
	awful.spawn.easy_async("dex -dae Awesome",
		function(stdout, stderr, _, exists)
			local exec
			for line in stdout:gmatch("[^\r\n]+")
			do
				spawn_checked({ exec = line:match("[^:]+: (.+)") })
			end
		end)

	for _, app in pairs(entries) do
		spawn_checked(app)
	end
end

function autostart.add(app)
	if type(app) == "table" then
		for _,ap in pairs(app) do
			local etr = type(ap) == "table" and ap or {}
			etr.exec = ap[1] or ap
			etr.check = ap[2]
			entries[etr.exec] = etr
		end
	else
		entries[app] = { exec = app }
	end
end

function autostart.addXDG()

end

return autostart
