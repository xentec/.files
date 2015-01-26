-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
wibox.layout.malign = require("layout-align")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local keys = require("keys")
local pulse = require("modules.pulse")
local common = require("common")
local autostart = require("modules.autostart")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
		naughty.notify({ preset = naughty.config.presets.critical,
										 title = "Oops, there were errors during startup!",
										 text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.warning,
						 title = "Oops, an error happened!",
						 text = err })
		in_error = false
	end)
end
-- }}}

naughty.config.notify_callback = function (args)
	args.icon_size = 16
	return args;
end

naughty.config.presets.warning = {
		bg = "#ffaa00",
		fg = "#ffffff",
		timeout = 10,
}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/xentec/.config/awesome/theme.lua")

browser = "chromium"
-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = "gedit "

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = keys.mod;

monitor = { main = 1 }

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
		awful.layout.suit.tile,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.tile.top,
		awful.layout.suit.fair,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.spiral,
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.max,
		awful.layout.suit.max.fullscreen,
		awful.layout.suit.magnifier,
		awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
tags[1] = awful.tag({ "main", "web", "chat", "code", "media", "other" }, 1, layouts[1])
for s = 2, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}
autostart.terminal = terminal

-- ########################################
-- ## Widgets
-- ########################################

widget = {}
widget.spacer = {}
widget.spacer.h = wibox.widget.textbox('<span color="gray"> ┆ </span>')
widget.spacer.v = wibox.widget.textbox('<span color="gray"> ┄</span>')

-- Layout
widget.layoutbox = {}

-- Clock
widget.clock = awful.widget.textclock('%H:%M %a %d.%m.%y')

--Battery
widget.battery = awful.widget.progressbar({ width = 50, height = 5 })
widget.battery:set_background_color("#00AAAA")
widget.battery.warning = {}
widget.battery.func = function(w, data)
	local low = 40
	local critical = 15

	if data[2] < critical and data[2] % 5 == 0 and w.warning ~= data[2] then
		naughty.notify({ preset = naughty.config.presets.critical,
						 title = "Battery charge is critical!",
						 text = data[2] .. " % remaining. Charge me up!" })
		w.warning = data[2]
	end

--[[	["Full\n"]        = "↯",
		["Unknown\n"]     = "⌁",
		["Charging\n"]    = "+",
		["Discharging\n"] = "-"		]]--
	w:set_color(data[1] == '↯' and '#00CCCC' or 
				data[2] > low and '#03cc00' or 
				data[2] > critical and '#FF7B00' or 
				'#EE0000')
	w:set_border_color(data[1] == '+' and '#00CCCC' or 
					   data[1] == '-' and data[2] <= critical and '#AA0000' or 
					   beautiful.bg_focus)
	w:set_background_color(data[1] == '⌁' and '#AA0000' or beautiful.bg_minimize)
	--naughty.notify({title = data[1], text = data[2]})
	return data[2]
end
vicious.register(widget.battery, vicious.widgets.bat, widget.battery.func, 2, 'BAT0')

-- Network
widget.network = wibox.widget.textbox()
vicious.register(widget.network, vicious.widgets.net, '<span color="DodgerBlue">↓ ${wlp3s0 down_kb} kb/s ↑ ${wlp3s0 up_kb} kb/s</span>', 2)

-- Wifi
widget.wifi = wibox.widget.textbox()
vicious.register(widget.wifi, vicious.widgets.wifi, '<span color="DarkCyan">${ssid} ${linp}%</span>', 5, 'wlp3s0')


-- Volume
widget.volume = awful.widget.progressbar({ width = 50, height = 4 })
widget.volume:set_background_color("#716D40")
widget.volume:set_color("#BDB76B")
widget.volume:set_max_value(100)

local volume = pulse(function(muted, val)
	if muted then
		widget.volume:set_color("#716D40")
	else
		widget.volume:set_color("#BDB76B")
	end
	widget.volume:set_value(val)
	if 	widget.volume.muted ~= muted then
		naughty.notify({text = muted and "Muted" or "Unmuted"})
	end
	widget.volume.muted = muted;
end)

-- CPU
widget.cpu = {}
widget.cpu.count = 4
for i = 1,widget.cpu.count do
	widget.cpu[i] = awful.widget.progressbar({ width = 50/widget.cpu.count })
	widget.cpu[i]:set_background_color("#876333")
	widget.cpu[i]:set_color("#DF8F26")
end
widget.cpu.func = function(w, data)
	for i = 1,w.count do
		w[i]:set_value(data[i+1]/100)
	end

	return data
end
vicious.register(widget.cpu, vicious.widgets.cpu, widget.cpu.func, 2)

-- Memory
widget.mem = awful.widget.progressbar({ width = 50, height = 4 })
widget.mem:set_background_color("#3A6D8A")
widget.mem:set_color("#269CDF")
vicious.register(widget.mem, vicious.widgets.mem, "$1")

-- ########################################
-- ## Bars
-- ########################################

bar = {}
bar.main = {}
bar.main = {}
bar.main.prompt = {}
bar.main.taglist = {}
bar.main.taglist.buttons = awful.util.table.join(
						awful.button({ update}, 1, awful.tag.viewonly),
						awful.button({ modkey }, 1, awful.client.movetotag),
						awful.button({ }, 3, awful.tag.viewtoggle),
						awful.button({ modkey }, 3, awful.client.toggletag),
						awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
						awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
					)
bar.main.tasklist = {}
bar.main.tasklist.buttons = awful.util.table.join(
						awful.button({ }, 1, function (c)
							if c == client.focus then
								c.minimized = true
							else
								-- Without this, the following
								-- :isvisible() makes no sense
								c.minimized = false
								if not c:isvisible() then
									awful.tag.viewonly(c:tags()[1])
								end
								-- This will also un-minimize
								-- the client, if needed
								client.focus = c
								c:raise()
							end
						end),
						 awful.button({ }, 3, function ()
							if instance then
								instance:hide()
								instance = nil
							else
								instance = awful.menu.clients({ width=250 })
							end
						end),
						awful.button({ }, 4, function ()
							awful.client.focus.byidx(1)
							if client.focus then client.focus:raise() end
						end),
						awful.button({ }, 5, function ()
							awful.client.focus.byidx(-1)
							if client.focus then client.focus:raise() end
						end)
					)

bar.main.tasklist.update = common.list_update
bar.main.layout_buttons = awful.util.table.join(
								awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
								awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
								awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
								awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end))


-- ########################################
-- ## Main screen
-- ########################################
do
	bar.main.prompt[monitor.main] = awful.widget.prompt()

	widget.layoutbox[monitor.main] = awful.widget.layoutbox(monitor.main)
	widget.layoutbox[monitor.main]:buttons(bar.main.layout_buttons)

	bar.main.taglist[monitor.main] = awful.widget.taglist(monitor.main, awful.widget.taglist.filter.all, bar.main.taglist.buttons)
	bar.main.tasklist[monitor.main] = awful.widget.tasklist(monitor.main, awful.widget.tasklist.filter.currenttags, bar.main.tasklist.buttons, nil, bar.main.tasklist.update)

	local left = wibox.layout.fixed.horizontal()
	left:add(bar.main.taglist[monitor.main])
	left:add(bar.main.prompt[monitor.main])
	left = wibox.widget.background(wibox.layout.margin(left,0,4), beautiful.bg_normal)

	local cpu = wibox.layout.fixed.horizontal()
	for i=1,widget.cpu.count do
		widget.cpu[i]:set_height(4)
		cpu:add(widget.cpu[i])
	end
	--widget.cpu:set_vertical(true)
	--widget.mem:set_vertical(true)
	--widget.battery:set_vertical(true)
	--widget.volume:set_vertical(true)
	local data_bars = wibox.layout.fixed.vertical()
	data_bars:add(cpu)
	--data_bars:add(widget.spacer.h)
	data_bars:add(widget.mem)
	--data_bars:add(widget.spacer.h)
	data_bars:add(widget.battery)
	--data_bars:add(widget.spacer.h)
	data_bars:add(widget.volume)
	data_bars = wibox.layout.margin(data_bars,0,0,2,2)


	local right = wibox.layout.fixed.horizontal()
	right:add(widget.network)
	right:add(widget.spacer.h)
	right:add(widget.wifi)
	right:add(widget.spacer.h)
	right:add(wibox.widget.systray())
	right:add(widget.spacer.h)
	right:add(data_bars)	
	right:add(widget.spacer.h)
	right:add(widget.clock)
	right:add(widget.spacer.h)
	right:add(widget.layoutbox[monitor.main])
	right = wibox.widget.background(wibox.layout.margin(right,4,4), beautiful.bg_normal)

	local layout = wibox.layout.malign.horizontal()
	layout:set_left(left)
	layout:set_middle(bar.main.tasklist[monitor.main])
	layout:set_right(right)

	bar.main[monitor.main] = awful.wibox({ position = "top", screen = monitor.main })
	bar.main[monitor.main]:set_bg(beautiful.bg_bg)
	bar.main[monitor.main]:set_widget(layout)
end

-- ########################################
-- ## Futher screens
-- ########################################

for s = 1, screen.count() do
	if s ~= monitor.main then
		-- Create an imagebox widget which will contains an icon indicating which layout we're using.
		-- We need one layoutbox per screen.
		widget.layoutbox[s] = awful.widget.layoutbox(s)
		widget.layoutbox[s]:buttons(bar.main.layout_buttons)
		-- Create a taglist widget
		bar.main.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, bar.main.taglist.buttons)

		-- Create a tasklist widget
		bar.main.tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, bar.main.tasklist.buttons, nil, bar.main.tasklist.update)

		-- Create the wibox
		bar.main[s] = awful.wibox({ position = "top", screen = s })

		-- Widgets that are aligned to the left
		local left = wibox.layout.fixed.horizontal()
		left:add(bar.main.taglist[s])
		left:add(widget.spacer.h)
		left:add(bar.main.prompt[monitor.main])

		-- Widgets that are aligned to the right
		local right = wibox.layout.fixed.horizontal()
		right:add(widget.clock)
		right:add(widget.spacer.h)
		right:add(widget.layoutbox[s])

		-- Now bring it all together (with the tasklist in the middle)
		local layout = wibox.layout.align.horizontal()
		layout:set_left(left)
		layout:set_middle(bar.main.tasklist[s])
		layout:set_right(right)

		bar.main[s]:set_widget(layout)
	end
end
-- }}}

root.keys(keys.global)

-- {{{ Rules
awful.rules.rules = awful.util.table.join(awful.rules.rules, require("rules"))
local rules = {
	{ rule = { class = "Chromium" },					properties = { tag = tags[1][2] } },
	{ rule = { class = "Firefox" },						properties = { tag = tags[1][2] } },
	{ rule = { class = "URxvt", instance = "irssi" },	properties = { tag = tags[1][3] } },
	{ rule = { class = "URxvt", instance = "weechat" },	properties = { tag = tags[1][3] } },
	{ rule = { class = "Steam" },						properties = { tag = tags[1][6] } },
	--{ rule_any = { class = { "mplayer2", "mplayer", "mpv" }},	properties = { tag = tags[1][5] } },
}
awful.rules.rules = awful.util.table.join(awful.rules.rules, rules)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
		-- Enable sloppy focus
		c:connect_signal("mouse::enter", function(c)
				if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
						and awful.client.focus.filter(c) then
						client.focus = c
				end
		end)

		if not startup then
				-- Set the windows at the slave,
				-- i.e. put it at the end of others instead of setting it master.
				-- awful.client.setslave(c)

				-- Put windows in a smart way, only if they does not set an initial position.
				if not c.size_hints.user_position and not c.size_hints.program_position then
						awful.placement.no_overlap(c)
						awful.placement.no_offscreen(c)
				end
		end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart
autostart.add({
--		"pulseaudio --start",
		"nitrogen --restore",
--		{"dropboxd","dropbox"},
	--	{"weechat", term = true},
	})
autostart.addDex()
autostart.launch()
-- }}}

