local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")

require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")

local lain = require("lain")
local vicious = require("vicious")

local keys = require("keys")
local mods = require("modules")

-- Override
-- nothing here (yet)

-- Short cuts
local markup = lain.util.markup
local color = markup.fg.color

-- Error handling
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
					 title = "Oops, there were errors during startup!",
					 text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", 
		function(err)
			-- Make sure we don't go into an endless error loop
			if in_error then return end
			in_error = true

			naughty.notify({ preset = naughty.config.presets.warning,
							 title = "Oops, an error happened!",
							 text = err })
			in_error = false
		end)
end

local awmL = awful.layout.suit
local lnL = lain.layout

-- Variable definitions
my = 
{
	theme = "/home/xentec/.config/awesome/theme.lua",

	browser = "chromium",
	terminal = "urxvtc",
	editor = os.getenv("EDITOR") or "nano",

	wallpapers = "~/lold/wg",
	autostart = {
--		{"dropboxd","dropbox"},
		"steam",
--		{"weechat", term = true},
--		"skype",
		"utox",
		"compton",
	},
	monitor = { 
		main =
		{
			i = 1,
			dpi = 158
		}, 
		info = {
			i = 2,
			dpi = 94
		} 
	},
	layout = {
		awmL.tile,
		awmL.tile.top,
		awmL.fair,
		awmL.fair.horizontal,
		awmL.corner.nw,
		awmL.floating
	},
	mpd = {
		host = "keeper",
		music_dir = "/mnt/fridge/music",
	},
	tags = {}
}

my.tags.config = {
	{ 
		names = { "main", "web", "code", "script", "media", "gaming", "other" },
		layout = my.layout[1]
	},
	{
		names = { "chat", "media", "vm" }, 
		layout = my.layout[2]
	}
}

my.editor_cmd = my.terminal .. " -e " .. my.editor

-- Set the terminal for applications that require it
menubar.utils.terminal = my.terminal
mods.autostart.terminal = my.terminal

beautiful.init(my.theme)
beautiful.xresources.set_dpi(my.monitor.main.dpi, my.monitor.main.i)
beautiful.xresources.set_dpi(my.monitor.info.dpi, my.monitor.info.i)

mods.wallpaper.add(my.wallpapers)
mods.wallpaper.init()

mods.autostart.add(my.autostart)
mods.autostart.addXDG()
mods.autostart.launch()


naughty.config.presets.warning = 
{
	bg = "#ffaa00",
	fg = "#ffffff",
	timeout = 10,
}


-- Tags
local tags = my.tags
for s = 1, screen.count() do
	if tags.config[s] then
		tags[s] = awful.tag(tags.config[s].names, s, tags.config[s].layout)
	else
		tags[s] = awful.tag({ 1, 2, 3, 4 }, s, my.layout[1])
	end
end

-- ##################################################
--                                                  
-- ▄     ▄   ▀        █                  ▄          
-- █  █  █ ▄▄▄     ▄▄▄█   ▄▄▄▄   ▄▄▄   ▄▄█▄▄   ▄▄▄  
-- █ █▀█ █   █    █▀ ▀█  █▀ ▀█  █▀  █    █    █   ▀ 
-- ▀██ ██▀   █    █   █  █   █  █▀▀▀▀    █     ▀▀▀▄ 
--  █   █  ▄▄█▄▄  ▀█▄██  ▀█▄▀█  ▀█▄▄▀    ▀▄▄  ▀▄▄▄▀ 
--                        ▄  █                      
--                         ▀▀                       
-- ##################################################

my.widget = {}
local widget = my.widget

widget.def = {}
widget.def.barLen = 100

widget.spacer = {}
widget.spacer.h = wibox.widget.textbox(color('gray', ' ┆ '))
widget.spacer.v = wibox.widget.textbox(color('gray', ' ┄'))

-- Layout
widget.layoutbox = {}

-- Clock
widget.clock = awful.widget.textclock('%H:%M %a %d.%m.%y')

-- Calendar
lain.widgets.calendar:attach(widget.clock, { font = beautiful.font_mono, cal = "/usr/bin/cal -3" })

-- Task
lain.widgets.contrib.task:attach(widget.clock)

-- Keyboard Layout
widget.kbd = awful.widget.keyboardlayout()


-- Network
widget.network = wibox.widget.textbox()
widget.network.func = function()
		local function humanBytes(bytes)
			local unit = {"K", "M", "G", "T", "P", "E"}
			local i = 1
			bytes = tonumber(bytes)
			while bytes > 1024 do
				bytes = bytes / 1024
				i = i+1
			end
			return bytes, unit[i]
		end

		local w = my.widget.network

		if net_now.carrier == "1" 
		then
			local down, down_suf = humanBytes(net_now.received);
			local up, up_suf = humanBytes(net_now.sent);

			w:set_markup(color("DodgerBlue", markup.monospace(string.format('↓ %5.1f %s ↑ %5.1f %s', down, down_suf, up, up_suf))))
		else
			w:set_markup(color("#8c8c8c", markup.monospace(' DC ')))
		end
	end
widget.network.worker = lain.widgets.net({ settings = widget.network.func })

-- Volume
widget.volume = awful.widget.progressbar({ width = widget.def.barLen })
widget.volume:set_background_color("#716D40")
widget.volume:set_color("#BDB76B")
widget.volume:set_max_value(100)
widget.volume.func = function(muted, val)
	if muted.speaker then
		widget.volume:set_color("#716D40")
	else
		widget.volume:set_color("#BDB76B")
	end
	widget.volume:set_value(val)
	--naughty.notify({text = muted and "Muted" or "Unmuted"})
end
local volume = mods.pulse(widget.volume.func, 5)

-- CPU
widget.cpu = {}
widget.cpu.count = 8
for i = 1,widget.cpu.count do
	widget.cpu[i] = awful.widget.progressbar({ width = widget.def.barLen })
	widget.cpu[i]:set_background_color("#876333")
	widget.cpu[i]:set_color("#DF8F26")
end
widget.cpu.temp = wibox.widget.textbox();
widget.cpu.func = function(w, data)
	for i = 1,w.count do
		w[i]:set_value(data[i+1]/100)
	end

	return data
end
vicious.register(widget.cpu, vicious.widgets.cpu, widget.cpu.func, 2)
vicious.register(widget.cpu.temp, vicious.widgets.thermal, color("#876333", markup.monospace(' $1°C')), 4, {'it87.552', 'core'})

-- Memory
widget.mem = {}
widget.mem.ram = awful.widget.progressbar({ width = widget.def.barLen })
widget.mem.ram:set_background_color("#3A6D8A")
widget.mem.ram:set_color("#269CDF")
widget.mem.swap = awful.widget.progressbar({ width = widget.def.barLen })
widget.mem.swap:set_background_color("#3A6D8A")
widget.mem.swap:set_color("#269CDF")
widget.mem.func = function()
	my.widget.mem.ram:set_value(mem_now.used/mem_now.total)
	my.widget.mem.swap:set_value(mem_now.swapused/(mem_now.swap or 1))
end
widget.mem.worker = lain.widgets.mem({ settings = widget.mem.func })

-- GPU
widget.gpu = {}
widget.gpu.gl = awful.widget.progressbar({ width = widget.def.barLen })
widget.gpu.gl:set_background_color("#4F8A3A")
widget.gpu.gl:set_color("#3FC51E")
widget.gpu.vl = awful.widget.progressbar({ width = widget.def.barLen })
widget.gpu.vl:set_background_color("#40702F")
widget.gpu.vl:set_color("#3FC51E")
widget.gpu.pcie = awful.widget.progressbar({ width = widget.def.barLen })
widget.gpu.pcie:set_background_color("#40702F")
widget.gpu.pcie:set_color("#3FC51E")
widget.gpu.mem = awful.widget.progressbar({ width = widget.def.barLen })
widget.gpu.mem:set_background_color("#4F8A3A")
widget.gpu.mem:set_color("#3FC51E")
widget.gpu.temp = wibox.widget.textbox();
widget.gpu.func = function()
	local w = my.widget.gpu

	w.gl:set_value(gpu_now.usage.graphics/100)
	w.vl:set_value(gpu_now.usage.video/100)
	w.pcie:set_value(gpu_now.usage.pcie/100)
	w.mem:set_value(gpu_now.mem.used/gpu_now.mem.total)
	w.temp:set_markup(color('#4F8A3A', markup.monospace(' '..gpu_now.temp..'°C')))
end
mods.gpu({ settings = widget.gpu.func })

-- MPD
widget.mpd = {}
widget.mpd.icon = wibox.widget.textbox()
widget.mpd.icon:set_font(theme.font_icon .. ' ' .. (theme.font_size + 2))
widget.mpd.nfo = wibox.widget.textbox()
widget.mpd.nfo:set_font(theme.font_name .. ' ' .. (theme.font_size - 2))
widget.mpd.bar = awful.widget.progressbar({ height = 2 })
widget.mpd.bar:set_background_color("#716D40")
widget.mpd.bar:set_color("#BDB76B")
widget.mpd.func = function()
	local d = mpd_now;
	local w = my.widget.mpd;

	local nfo = ""
	local time = 0
	local state = {
		play = '&#xF04B;',
		pause = '&#xF04C;',
		stop = '&#xF04D;'
	}

	if state[d.state] then
		w.icon:set_markup(color('#BDB76B', state[d.state]));

		if d.title ~= "N/A" then
			nfo = d.title
		elseif d.state == "play" then
			nfo = d.name or d.file
		end
		if d.artist ~= "N/A" then
			nfo = d.artist..' - '..nfo
		end
				
		if tonumber(d.elapsed) ~= nil and tonumber(d.time) ~= nil then
			time = tonumber(d.elapsed)/tonumber(d.time)
		end
	else
		w.icon:set_markup(color('#716D40', state.stop));
	end

	w.bar:set_width(nfo:len())
	w.nfo:set_markup(color('#BDB76B', nfo))
	w.bar:set_value(time)
end
widget.mpd.worker = lain.widgets.mpd({
	timeout = 2,
	host = my.mpd.host,
	music_dir = my.mpd.music_dir,
	settings = widget.mpd.func,
})


-- ########################################
-- ▄    ▄   ▀                 
-- ██  ██ ▄▄▄     ▄▄▄    ▄▄▄  
-- █ ██ █   █    █   ▀  █▀  ▀ 
-- █ ▀▀ █   █     ▀▀▀▄  █     
-- █    █ ▄▄█▄▄  ▀▄▄▄▀  ▀█▄▄▀  
-- 
-- ########################################

-- Set keys
root.keys(keys.global);

-- Rules per monitor
local rules =
{
	{
		{ rule = { class = "Chromium" },					properties = { tag = 2 } },
		{ rule = { class = "Firefox" },						properties = { tag = 2 } },
		{ rule = { class = "Steam" },						properties = { tag = 6 },
			callback = function(c)
				if c.name:find("Chat",1,true) then
					c.screen = awful.tag.getscreen(tags[2][1])
					c:tags({ tags[2][1] })
					awful.client.floating.set(c, false)
				end
			end
		},
	},
	{
		{ rule = { class = "URxvt", instance = "irssi" },	properties = { tag = 1 } },
		{ rule = { class = "URxvt", instance = "weechat" },	properties = { tag = 1 } },
		{ rule = { class = "Skype" },						properties = { tag = 1 } },
		{ rule = { class = "Pidgin" },						properties = { tag = 1 } },
		{ rule = { class = "utox" },						properties = { tag = 1 } },
	}
}
awful.rules.rules = awful.util.table.join(awful.rules.rules, require("rules"))
for s = 1, screen.count()
do
	if rules[s] ~= nil
	then
		for _,rule in pairs(rules[s])
		do
			if rule.properties and rule.properties.tag
			then
				rule.properties.tag = tags[s][rule.properties.tag]
			end
		end
		awful.rules.rules = awful.util.table.join(awful.rules.rules, rules[s])
	end
end
----


-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c) 
		if not awesome.startup then
			-- Set the windows at the slave,
			-- i.e. put it at the end of others instead of setting it master.
			-- awful.client.setslave(c)

			-- Put windows in a smart way, only if they do not set an initial position.
			if not c.size_hints.user_position and not c.size_hints.program_position then
				awful.placement.no_overlap(c)
				awful.placement.no_offscreen(c)
			end
		elseif not (c.size_hints.user_position or c.size_hints.program_position) then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end
	end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)
----

-- ########################################
-- ▄    ▄  ▄▄▄▄  ▄▄   ▄ ▄▄▄▄▄ ▄▄▄▄▄▄▄  ▄▄▄▄  ▄▄▄▄▄ 
-- ██  ██ ▄▀  ▀▄ █▀▄  █   █      █    ▄▀  ▀▄ █   ▀█
-- █ ██ █ █    █ █ █▄ █   █      █    █    █ █▄▄▄▄▀
-- █ ▀▀ █ █    █ █  █ █   █      █    █    █ █   ▀▄
-- █    █  █▄▄█  █   ██ ▄▄█▄▄    █     █▄▄█  █    █
--
-- ########################################

local monitor = my.monitor

-- Common buttons
local buttons = 
{
	taglist = awful.util.table.join(
		awful.button({}, 1, awful.tag.viewonly),
		awful.button({ keys.mod }, 1, awful.client.movetotag),
		awful.button({}, 3, awful.tag.viewtoggle),
		awful.button({ keys.mod }, 3, awful.client.toggletag)
	),
	tasklist = awful.util.table.join(
		awful.button({}, 1, function(c)
			if c == client.focus then
				c.minimized = true
			else
				-- Without this, the following
				-- :isvisible() makes no sense
				c.minimized = false
				if not c:isvisible() then
					awful.tag.viewonly(c.first_tag)
				end
				-- This will also un-minimize
				-- the client, if needed
				client.focus = c
				c:raise()
			end
		end),
		 awful.button({}, 3, function()
			if instance then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ width=250 })
			end
		end),
		awful.button({}, 4, function()
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		end),
		awful.button({}, 5, function()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end)
	),
	layoutbox = awful.util.table.join(
		awful.button({}, 1, function() awful.layout.inc(my.layout, 1) end),
		awful.button({}, 3, function() awful.layout.inc(my.layout, -1) end)
	)
}
-- ########################################
-- ## Main screens
-- ########################################

-- Main ###################################
do
	local s = monitor.main.i

	monitor.main.prompt = awful.widget.prompt()
	
	monitor.main.layoutbox = awful.widget.layoutbox(s)
	monitor.main.layoutbox:buttons(buttons.layoutbox)

	monitor.main.taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, buttons.taglist)
	monitor.main.tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, buttons.tasklist)

	local left = wibox.layout.fixed.horizontal()
	left:add(monitor.main.layoutbox)
	left:add(widget.spacer.h)
	left:add(monitor.main.taglist)
	left:add(monitor.main.prompt)
	left = wibox.widget.background(wibox.layout.margin(left,0,4))

	local right = wibox.layout.fixed.horizontal()
	right:add(wibox.widget.systray())
	right:add(widget.spacer.h)
	right:add(widget.kbd)
	right:add(widget.spacer.h)
	right:add(widget.clock)
	right = wibox.widget.background(wibox.layout.margin(right,4,4))

	local layout = wibox.layout.align.horizontal(left, monitor.main.tasklist, right)

	monitor.main.bar = awful.wibox({ position = "top", screen = s })
	monitor.main.bar:set_bg(beautiful.bg_bg)
	monitor.main.bar:set_widget(layout)
end

-- Info ###################################
if screen.count() > 1 then

	monitor.info.bar = {}

	local s = monitor.info.i	
	do
		monitor.info.layoutbox = awful.widget.layoutbox(s)
		monitor.info.layoutbox:buttons(buttons.layoutbox)

		monitor.info.taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, buttons.taglist)
		monitor.info.tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, buttons.tasklist)

		local left = wibox.layout.fixed.horizontal()
		left:add(monitor.info.layoutbox)
		left:add(widget.spacer.h)
		left:add(monitor.info.taglist)
		left:add(widget.spacer.h)
		left:add(monitor.main.prompt) -- ! two prompts are overkill
		left = wibox.widget.background(wibox.layout.margin(left,0,4))

		local right = wibox.layout.fixed.horizontal()
		right:add(widget.clock)
		right = wibox.widget.background(wibox.layout.margin(right,4,4))

		local layout = wibox.layout.align.horizontal(left, monitor.info.tasklist, right)

		monitor.info.bar.top = awful.wibox({ position = "top", screen = s, height = 24 })
		monitor.info.bar.top:set_bg(beautiful.bg_bg)
		monitor.info.bar.top:set_widget(layout)
	end

	--=======================================================

	do
		local cpu = wibox.layout.fixed.vertical()
		for i=1,widget.cpu.count do
			widget.cpu[i]:set_height(16/widget.cpu.count)
			cpu:add(widget.cpu[i])
		end

		local mem = wibox.layout.fixed.vertical()
		widget.mem.ram:set_height(8)
		widget.mem.swap:set_height(8)
		mem:add(widget.mem.ram)
		mem:add(widget.mem.swap)

		local gpu = wibox.layout.fixed.vertical()
		gpu.usage = wibox.layout.fixed.horizontal()
		gpu.usage.sub = wibox.layout.fixed.vertical()
		widget.gpu.gl:set_height(8)
		widget.gpu.gl:set_width(widget.def.barLen*2/3)
		widget.gpu.vl:set_height(4)
		widget.gpu.vl:set_width(widget.def.barLen/3)
		widget.gpu.pcie:set_height(4)
		widget.gpu.pcie:set_width(widget.def.barLen/3)
		widget.gpu.mem:set_height(8)
		gpu.usage.sub:add(widget.gpu.vl)
		gpu.usage.sub:add(widget.gpu.pcie)
		gpu.usage:add(widget.gpu.gl)
		gpu.usage:add(gpu.usage.sub)
		gpu:add(gpu.usage)
		gpu:add(widget.gpu.mem)

		local mpd = wibox.layout.fixed.horizontal()
		mpd.ib = wibox.layout.fixed.vertical()
		mpd.ib:add(widget.mpd.nfo)
		mpd.ib:add(widget.mpd.bar)
		mpd:add(wibox.layout.margin(widget.mpd.icon,4,8))
		mpd:add(mpd.ib)

		local left = wibox.layout.fixed.horizontal()
		left:add(cpu)
		left:add(widget.cpu.temp)
		left:add(widget.spacer.h)
		left:add(mem)
		left:add(widget.spacer.h)
		left:add(gpu)
		left:add(widget.gpu.temp)
		left:add(widget.spacer.h)
		left:add(widget.network)
		left = wibox.widget.background(wibox.layout.margin(left,4,4,3,3))

		local right = wibox.layout.fixed.horizontal()
		right:add(wibox.layout.constraint(mpd, 'max', 600))
		right:add(widget.spacer.h)
		right:add(widget.volume)
		right = wibox.widget.background(wibox.layout.margin(right,4,4,3,3))

		local layout = wibox.layout.align.horizontal()
		layout:set_left(left)
		layout:set_right(right)

		monitor.info.bar.bottom = awful.wibox({ position = "bottom", screen = s, height = 24 })
		monitor.info.bar.bottom:set_bg(beautiful.bg_bg)
		monitor.info.bar.bottom:set_widget(layout)
	end

	-- ########################################
	-- ## Futher screens
	-- ########################################

	for s = 3, screen.count() do
		-- Create an imagebox widget which will contains an icon indicating which layout we're using.
		-- We need one layoutbox per screen.
		monitor[s].layoutbox = awful.widget.layoutbox(s)
		widget.layoutbox:buttons(buttons.layoutbox)
		-- Create a taglist widget
		monitor[s].taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, buttons.taglist)

		-- Create a tasklist widget
		monitor[s].tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, buttons.tasklist)

		-- Widgets that are aligned to the left
		local left = wibox.layout.fixed.horizontal()
		left:add(monitor[s].taglist)
		left:add(monitor.main.prompt)

		-- Widgets that are aligned to the right
		local right = wibox.layout.fixed.horizontal()
		right:add(widget.clock)
		right:add(widget.layoutbox)

		-- Now bring it all together (with the tasklist in the middle)
		local layout = wibox.layout.align.horizontal()
		layout:set_left(left)
		layout:set_middle(monitor[s].tasklist)
		layout:set_right(right)

		-- Create the wibox
		monitor[s].bar = awful.wibox({ position = "top", screen = s })		
		monitor[s].bar:set_bg(beautiful.bg_bg)
		monitor[s].bar:set_widget(layout)
	end
end

