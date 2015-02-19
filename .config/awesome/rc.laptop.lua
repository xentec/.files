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
local common = require("common")

local mods = require("modules")

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
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor


mods.wallpaper.add('~/lold/wg')

-- Autostart
mods.autostart.add({
--		{"dropboxd","dropbox"},
--		{"weechat", term = true},
	})

mods.autostart.addXDG()

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = keys.mod;

monitor = { main = 1 }

-- Table of layouts to cover with awful.layout.inc, order matters.
local layout = awful.layout.suit
layouts =
{
		layout.tile,
		layout.tile.left,
		layout.tile.bottom,
		layout.tile.top,
		layout.fair,
		layout.fair.horizontal,
		layout.spiral,
		layout.spiral.dwindle,
		layout.max,
		layout.max.fullscreen,
		layout.magnifier,
		layout.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
	names = { "main", "web", "chat", "code", "media", "other" }
}
tags[1] = awful.tag(tags.names, 1, layouts[1])
for s = 2, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
end
-- }}}

-- Set the terminal for applications that require it
menubar.utils.terminal = terminal 
mods.autostart.terminal = terminal

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

-- Network
widget.network = wibox.widget.textbox()
widget.network.func = function (w, data)
	local ret = {}
	if data['{en carrier}'] == 1 then
		ret = { col = "DodgerBlue", d = data['{en down_sb}'], ds = data['{en down_suf}'], u = data['{en up_sb}'], us = data['{en up_suf}'] }
	elseif data['{wl carrier}'] == 1 then
		ret = { col = "DodgerBlue", d = data['{wl down_sb}'], ds = data['{wl down_suf}'], u = data['{wl up_sb}'], us = data['{wl up_suf}'] }
	else
		return '<span color="#8c8c8c"> Disconnected </span>'
	end
	return string.format('<span color="%s">↓ %5.1f %s ↑ %5.1f %s</span>', ret.col, ret.d, ret.ds, ret.u, ret.us)
end
vicious.register(widget.network, mods.net, widget.network.func, 2)

-- Volume
widget.volume = {} --awful.widget.progressbar({ width = 50 })
widget.volume.icon = wibox.widget.textbox()
--widget.volume.icon:set_font(theme.font_name .. ' ' .. (theme.font_size + 2))
widget.volume.data = wibox.widget.textbox()
widget.volume.func = function(muted, val)
	local data_color = "#BDB76B"
	local icon = "&#xf0ba;"
	if muted then
		icon = "&#xf080;"
		data_color = "#716D40"
	end
	widget.volume.icon:set_markup(string.format('<span color="#BDB76B">%s</span>', icon))
	widget.volume.data:set_markup(string.format('<span color="%s"> %3.0f</span>', data_color, val))
	
	if widget.volume.muted ~= muted then
		naughty.notify({
			title = "Sound", 
			text = muted and "Muted" or "Unmuted"
		})
	end
	widget.volume.muted = muted;
end
local volume = mods.pulse(widget.volume.func, 5)

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
--vicious.register(widget.cpu, vicious.widgets.cpu, widget.cpu.func, 2)

-- Memory
widget.mem = awful.widget.progressbar({ width = 50 })
widget.mem:set_background_color("#3A6D8A")
widget.mem:set_color("#269CDF")
--vicious.register(widget.mem, vicious.widgets.mem, "$1")

-- Wifi
widget.wifi = {}
widget.wifi.icon = wibox.widget.textbox('<span color="DarkCyan">&#xf034;</span>')
--widget.wifi.icon:set_font(theme.font_name .. ' ' .. (theme.font_size + 2))
widget.wifi.data =  wibox.widget.textbox()
widget.wifi.tip = awful.tooltip({
	objects = { widget.wifi.icon, widget.wifi.data },
	timer_function = function()
		return string.format('<span color="DarkCyan">%s</span>', widget.wifi.tipdata)
	end,
})
widget.wifi.func = function(w, data)
	local s = data['{ssid}'].."\n"
--	s = s.."Channel: "..data['{chan}'].."\n"
	s = s.."Bit rate: "..data['{rate}'].." MB/s"
	widget.wifi.tipdata = s

	return string.format('<span color="DarkCyan"> %3.0f</span>', data['{linp}'])
end
vicious.register(widget.wifi.data, vicious.widgets.wifi, widget.wifi.func, 2, 'wl')

-- Battery 
widget.battery = {} 
widget.battery.icon = wibox.widget.textbox('&#xE001;')
widget.battery.icon:set_font('flaticon '..theme.font_size)
widget.battery.data = wibox.widget.textbox()
widget.battery.warning = 0
--[[widget.battery.tip = awful.tooltip({
	objects = { widget.battery.icon },
	timer_function = function()
		--return '<span color="DarkCyan"> '..widget.battery.data..' </span>'
	end,
})]]
widget.battery.func = function(w, data)
	local low = 40
	local critical = 15

--[[	["Full\n"]        = "↯",
		["Unknown\n"]     = "⌁",
		["Charging\n"]    = "+",
		["Discharging\n"] = "−"		]]--
	if data[1] == '−' and data[2] <= critical and w.warning ~= data[2] and (w.warning == 0 or data[2] % 5 == 0) then
		naughty.notify({ preset = naughty.config.presets.critical,
						 title = " Battery",
						 text = string.format("%3.0f %% remaining. Charge me up!", data[2]) })
		w.warning = data[2]
	end

	local icon =	'&#xE002;'
--[[	local icon = 	(data[1] == '+' or data[1] == '↯') and '&#xE001;'  or 
					data[2] > 80 and '&#xE006;' or 
					data[2] > 60 and '&#xE004;' or
					data[2] > 40 and '&#xE002;' or
					data[2] > 20 and '&#xE005;' or 
					data[2] > 5  and '&#xE003;' or 
									 '&#xE007;'
]]

	local color = 	data[1] == '↯' and '#00CCCC' or 
					data[1] == '+' and '#00CCCC' or
					data[2] > low and '#03cc00' or 
					data[2] > critical and '#FBE72A' or 
										'#FB6B24'
	--naughty.notify({title = data[1], text = data[2]})
	w.icon:set_markup(string.format('<span color="%s">%s</span>', color, icon))
	w.data:set_markup(string.format('<span color="%s">%3.0f</span>', color, data[2]))
	return
end
vicious.register(widget.battery, vicious.widgets.bat, widget.battery.func, 2, 'BAT0')

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
	left:add(wibox.widget.systray())
	left:add(bar.main.prompt[monitor.main])
	left = wibox.widget.background(wibox.layout.margin(left,0,4), beautiful.bg_normal)

	local cpu = wibox.layout.fixed.horizontal()
	for i=1,widget.cpu.count do
		widget.cpu[i]:set_height(4)
		cpu:add(widget.cpu[i])
	end

	local right = wibox.layout.fixed.horizontal()
	right:add(widget.network)
	right:add(widget.spacer.h)
	right:add(widget.wifi.icon)
	right:add(widget.wifi.data)
	right:add(widget.spacer.h)

	right:add(widget.volume.icon)
	right:add(widget.volume.data)
	right:add(widget.spacer.h)
	right:add(widget.battery.icon)
	right:add(widget.battery.data)
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
	{ rule_any = { class = { "mplayer2", "mplayer", "mpv" }},	properties = { tag = tags[1][5] } },
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
				awful.client.setslave(c)

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

mods.wallpaper.init()
mods.autostart.launch()