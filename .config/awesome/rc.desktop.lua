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
local pulse = require("modules.pulse")
local mpd = require("modules.mpd")
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
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = keys.mod;

monitor = { main = 1, info = 2 }

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
tags[1] = awful.tag({ "main", "web", "code", "script", "media", "gaming", "other" }, 1, layouts[1])
tags[2] = awful.tag({ "chat", "web", "media", "vm"}, 2, layouts[1])
for s = 3, screen.count() do
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
widget.clock = awful.widget.textclock('%H:%M %d.%m.%y')

-- Network
widget.network = wibox.widget.textbox()
vicious.register(widget.network, vicious.widgets.net, '<span color="DodgerBlue">↓ ${enp5s0 down_kb} kb/s ↑ ${enp5s0 up_kb} kb/s</span>', 1)

-- Volume
widget.volume = awful.widget.progressbar({ width = 100 })
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
	--naughty.notify({text = muted and "Muted" or "Unmuted"})
end, 5)

-- CPU
widget.cpu = {}
for i = 1,8 do
	widget.cpu[i] = awful.widget.progressbar({ width = 100 })
	widget.cpu[i]:set_background_color("#876333")
	widget.cpu[i]:set_color("#DF8F26")
end
vicious.register(widget.cpu, vicious.widgets.cpu, function(w, data)
	for i = 1,#w do
		w[i]:set_value(data[i+1]/100)
	end

	return data
end, 2)

-- Memory
widget.mem = {}
widget.mem.ram = awful.widget.progressbar({ width = 100 })
widget.mem.ram:set_background_color("#3A6D8A")
widget.mem.ram:set_color("#269CDF")
widget.mem.swap = awful.widget.progressbar({ width = 100 })
widget.mem.swap:set_background_color("#3A6D8A")
widget.mem.swap:set_color("#269CDF")
vicious.register(widget.mem, vicious.widgets.mem, function(w, data)
	w.ram:set_value(data[1]/100)
	w.swap:set_value(data[5]/100)
	return data
end)

-- GPU
widget.gpu = {}
widget.gpu.gl = awful.widget.progressbar({ width = 100 })
widget.gpu.gl:set_background_color("#4F8A3A")
widget.gpu.gl:set_color("#3FC51E")
widget.gpu.vl = awful.widget.progressbar({ width = 100 })
widget.gpu.vl:set_background_color("#4F8A3A")
widget.gpu.vl:set_color("#3FC51E")
widget.gpu.mem = awful.widget.progressbar({ width = 100 })
widget.gpu.mem:set_background_color("#4F8A3A")
widget.gpu.mem:set_color("#3FC51E")
widget.gpu.temp = wibox.widget.textbox();
--widget.gpu.temp:set_color("#3FC51E")
vicious.register(widget.gpu, require("modules.gpu-nv"), function(w, data)
	for k, v in string.gmatch(data[1], "(%w+)=(%w+)") do
		v = tonumber(v)/100
		if(k == "graphics") then
			w.gl:set_value(v)
		elseif(k == "video") then
			w.vl:set_value(v)
		end
	end

	w.mem:set_value(tonumber(data[2])/tonumber(data[3]))
	w.temp:set_markup(' <span color="#3FC51E">'..data[4]..' °C</span>')
	return data
end, 2, { query = { "[gpu:0]/GPUUtilization", "[gpu:0]/UsedDedicatedGPUMemory", "[gpu:0]/TotalDedicatedGPUMemory", "[gpu:0]/GPUCoreTemp" } })

-- MPD
widget.mpd = {}
widget.mpd.icon = wibox.widget.textbox()
widget.mpd.icon:set_font('octicons')
widget.mpd.nfo = wibox.widget.textbox()
widget.mpd.nfo:set_font(theme.font_name .. ' ' .. (theme.font_size - 2))
widget.mpd.bar = awful.widget.progressbar({ height = 2 })
widget.mpd.bar:set_background_color("#716D40")
widget.mpd.bar:set_color("#BDB76B")

vicious.register(widget.mpd, mpd, function(w, data)
	local state = {
		play = '&#xF0BF;',
		pause = '&#xF0BB;',
		stop = '&#xF053;'
	}
	if state[data['{state}']] then
		w.icon:set_markup('<span color="#BDB76B">'.. state[data['{state}']] ..'</span>');
	end

	local nfo = '<span color="#BDB76B">'..data['{Artist}']..' :: '..data['{Title}']..'</span>';
	w.bar:set_width(nfo:len())

	w.nfo:set_markup(nfo)
	w.bar:set_value(data['{elapsed}'] / data['{Time}'])
	return data
end, 1, {host = "keeper"})
vicious.cache(widget.mpd)

-- ########################################
-- ## Bars
-- ########################################

bar = {}
bar.main = {}
bar.main.prompt = {}
bar.main.taglist = {}
bar.main.taglist.buttons = awful.util.table.join(
						awful.button({ update}, 1, awful.tag.viewonly),
						awful.button({ modkey }, 1, awful.client.movetotag),
						awful.button({ }, 3, awful.tag.viewtoggle),
						awful.button({ modkey }, 3, awful.client.toggletag)
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
								awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)
							)

bar.info = {}

-- ########################################
-- ## Main screens
-- ########################################

	-- Main ###################################
do

	bar.main.prompt[monitor.main] = awful.widget.prompt()

	widget.layoutbox[monitor.main] = awful.widget.layoutbox(monitor.main)
	widget.layoutbox[monitor.main]:buttons(bar.main.layout_buttons)

	bar.main.taglist[monitor.main] = awful.widget.taglist(monitor.main, awful.widget.taglist.filter.all, bar.main.taglist.buttons)
	bar.main.tasklist[monitor.main] = awful.widget.tasklist(monitor.main, awful.widget.tasklist.filter.currenttags, bar.main.tasklist.buttons, nil, bar.main.tasklist.update)

	local left = wibox.layout.fixed.horizontal()
	left:add(widget.layoutbox[monitor.main])
	left:add(widget.spacer.h)
	left:add(bar.main.taglist[monitor.main])
	left:add(bar.main.prompt[monitor.main])
	left = wibox.widget.background(wibox.layout.margin(left,0,4), beautiful.bg_normal)

	local right = wibox.layout.fixed.horizontal()
	right:add(wibox.widget.systray())
	right:add(widget.spacer.h)
	right:add(widget.clock)
	right = wibox.widget.background(wibox.layout.margin(right,4,4), beautiful.bg_normal)

	local layout = wibox.layout.malign.horizontal()
	layout:set_left(left)
	layout:set_middle(bar.main.tasklist[monitor.main])
	layout:set_right(right)

	bar.main[monitor.info] = awful.wibox({ position = "top", screen = monitor.main })
	bar.main[monitor.info]:set_bg(beautiful.bg_bg)
	bar.main[monitor.info]:set_widget(layout)
end

	-- Info ###################################

if screen.count() > 1 then
	do
		widget.layoutbox[monitor.info] = awful.widget.layoutbox(monitor.info)
		widget.layoutbox[monitor.info]:buttons(bar.main.layout_buttons)

		bar.main.taglist[monitor.info] = awful.widget.taglist(monitor.info, awful.widget.taglist.filter.all, bar.main.taglist.buttons)
		bar.main.tasklist[monitor.info] = awful.widget.tasklist(monitor.info, awful.widget.tasklist.filter.currenttags, bar.main.tasklist.buttons, nil, bar.main.tasklist.update)

		local left = wibox.layout.fixed.horizontal()
		left:add(widget.layoutbox[monitor.info])
		left:add(widget.spacer.h)
		left:add(bar.main.taglist[monitor.info])
		left:add(widget.spacer.h)
		left:add(bar.main.prompt[monitor.main])
		--left:add(bar.main.tasklist[monitor.info])
		left = wibox.widget.background(wibox.layout.margin(left,0,4), beautiful.bg_normal)

		local right = wibox.layout.fixed.horizontal()
		right:add(widget.clock)
		right = wibox.widget.background(wibox.layout.margin(right,4,4), beautiful.bg_normal)

		local layout = wibox.layout.malign.horizontal()
		layout:set_left(left)
		layout:set_middle(bar.main.tasklist[monitor.info])
		layout:set_right(right)

		bar.main["iu"] = awful.wibox({ position = "top", screen = monitor.info })
		bar.main["iu"]:set_bg(beautiful.bg_bg)
		bar.main["iu"]:set_widget(layout)
	end

	--=======================================================

	do
		local cpu = wibox.layout.fixed.vertical()
		for i=1,#widget.cpu do
			widget.cpu[i]:set_height(16/#widget.cpu)
			cpu:add(widget.cpu[i])
		end

		local mem = wibox.layout.fixed.vertical()
		widget.mem.ram:set_height(12)
		widget.mem.swap:set_height(4)
		mem:add(widget.mem.ram)
		mem:add(widget.mem.swap)

		local gpu = wibox.layout.fixed.vertical()
		widget.gpu.gl:set_height(6)
		widget.gpu.vl:set_height(2)
		widget.gpu.mem:set_height(8)
		gpu:add(widget.gpu.gl)
		gpu:add(widget.gpu.vl)
		gpu:add(widget.gpu.mem)

		local mpd = {}
		mpd.ib = wibox.layout.fixed.vertical()
		mpd.ib:add(widget.mpd.nfo)
		mpd.ib:add(widget.mpd.bar)
		mpd.w = wibox.layout.fixed.horizontal()
		mpd.w:add(wibox.layout.margin(widget.mpd.icon,4,8))
		mpd.w:add(mpd.ib)

		local left = wibox.layout.fixed.horizontal()
		left:add(cpu)
		left:add(widget.spacer.h)
		left:add(mem)
		left:add(widget.spacer.h)
		left:add(gpu)
		left:add(widget.gpu.temp)
		left:add(widget.spacer.h)
		left:add(widget.network)
		left = wibox.widget.background(wibox.layout.margin(left,4,4,3,3), beautiful.bg_normal)

		local right = wibox.layout.fixed.horizontal()
		right:add(wibox.layout.constraint(mpd.w,'max', 600))
		right:add(widget.spacer.h)
		right:add(widget.volume)
		right = wibox.widget.background(wibox.layout.margin(right,4,4,3,3), beautiful.bg_normal)

		local layout = wibox.layout.align.horizontal()
		layout:set_left(left)
		layout:set_right(right)

		bar.info["ib"] = awful.wibox({ position = "bottom", screen = monitor.info })
		bar.info["ib"]:set_bg(beautiful.bg_bg)
		bar.info["ib"]:set_widget(layout)
	end
end

-- ########################################
-- ## Futher screens
-- ########################################

for s = 1, screen.count() do
	if not awful.util.table.hasitem(monitor, s) then
		-- Create an imagebox widget which will contains an icon indicating which layout we're using.
		-- We need one layoutbox per screen.
		widget.layoutbox[s] = awful.widget.layoutbox(s)
		widget.layoutbox[s]:buttons(bar.main.layout_buttons)
		-- Create a taglist widget
		bar.main.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, bar.main.taglist.buttons)

		-- Create a tasklist widget
		bar.main.tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, bar.main.tasklist.buttons, nil, bar.main.tasklist.update)

		-- Widgets that are aligned to the left
		local left = wibox.layout.fixed.horizontal()
		left:add(bar.main.taglist[s])
		left:add(bar.main.prompt[monitor.main])

		-- Widgets that are aligned to the right
		local right = wibox.layout.fixed.horizontal()
		right:add(widget.clock)
		right:add(widget.layoutbox[s])

		-- Now bring it all together (with the tasklist in the middle)
		local layout = wibox.layout.align.horizontal()
		layout:set_left(left)
		layout:set_middle(bar.main.tasklist[s])
		layout:set_right(right)

		-- Create the wibox
		bar.main[s] = awful.wibox({ position = "top", screen = s })
		bar.main[s]:set_widget(layout)
	end
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- Set keys
root.keys(keys.global);
-- }}}

-- {{{ Rules
awful.rules.rules = awful.util.table.join(awful.rules.rules, require("rules"))
local rules = {
	{ rule = { class = "Chromium" },					properties = { tag = tags[1][2] } },
	{ rule = { class = "Firefox" },						properties = { tag = tags[1][2] } },
	{ rule = { class = "URxvt", instance = "irssi" },	properties = { tag = tags[2][1] } },
	{ rule = { class = "URxvt", instance = "weechat" },	properties = { tag = tags[2][1] } },
	{ rule = { class = "Skype" },						properties = { tag = tags[2][1] } },
	{ rule = { class = "Pidgin" },						properties = { tag = tags[2][1] } },
	{ rule = { class = "Steam" },						properties = { tag = tags[1][6] },
		callback = function (c)
			if c.name:find("Chat",1,true) then
				c.screen = awful.tag.getscreen(tags[2][1])
            	c:tags({ tags[2][1] })
            	awful.client.floating.set(c, false)
			end
		end
	},

	--{ rule_any = { class = { "mplayer", "mplayer2", "mpv" }},	properties = { tag = tags[2][3] } },
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

			local g = c:geometry()
			--require("gears.debug").dump(g)
			if(g.width < 800 or g.height < 600) then
			--	awful.client.floating.set(c, true);
			end
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
		"pulseaudio",
		"nitrogen --restore",
		{"dropboxd","dropbox"},
		"steam",
--		{"weechat", term = true},
		"skype",
	})
autostart.launch()
-- }}}
