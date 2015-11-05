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
	editor = os.getenv("EDITOR") or "vim",

	wallpapers = "~/lold/wg",
	autostart = {
--		{"dropboxd","dropbox"},
--		{"weechat", term = true},
	},
	monitor = { 
		main =
		{
			i = 1,
			dpi = 96
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
		host = "localhost",
		music_dir = "~/mobile.music"
	},
	tags = {}
}

my.tags.config = {
	{
		names = { "main", "web", "chat", "code", "media", "other" },
		layout = my.layout[1]
	}
}

my.editor_cmd = my.terminal .. " -e " .. my.editor

-- Set the terminal for applications that require it
menubar.utils.terminal = my.terminal
mods.autostart.terminal = my.terminal

beautiful.init(my.theme)
for mon in pairs(my.monitor) do
	beautiful.xresources.set_dpi(mon.dpi, mon.i)
end

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

-- ########################################
--                                                  
-- ▄     ▄   ▀        █                  ▄          
-- █  █  █ ▄▄▄     ▄▄▄█   ▄▄▄▄   ▄▄▄   ▄▄█▄▄   ▄▄▄  
-- ▀ █▀█ █   █    █▀ ▀█  █▀ ▀█  █▀  █    █    █   ▀ 
--  ██ ██▀   █    █   █  █   █  █▀▀▀▀    █     ▀▀▀▄ 
--  █   █  ▄▄█▄▄  ▀█▄██  ▀█▄▀█  ▀█▄▄▀    ▀▄▄  ▀▄▄▄▀ 
--                        ▄  █                      
--                         ▀▀                       
-- ########################################

my.widget = {}
local widget = my.widget

widget.spacer = {}
widget.spacer.h = wibox.widget.textbox(color('gray', ' ┆ '))
widget.spacer.v = wibox.widget.textbox(color('gray', ' ┄'))

-- Layout
widget.layoutbox = {}

-- Clock
widget.clock = awful.widget.textclock('%H:%M %a %d.%m.%y')

-- Calendar
lain.widgets.calendar:attach(widget.clock, { font = beautiful.font_mono, cal = "/usr/bin/cal -n 2" })

-- Network
widget.network = wibox.widget.textbox()
widget.network.func = 
	function()
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
widget.volume = {}
widget.volume.icon = wibox.widget.textbox()
widget.volume.icon:set_font(theme.font_icon .. ' ' .. (theme.font_size + 2))
widget.volume.data = wibox.widget.textbox()
widget.volume.func = 
function(mute, val)
	local w = my.widget.volume

	local spkr = { icon = '&#xF028;', color = "#BDB76B" }
	local mic = { icon = '&#xF130;', color = "#BDB76B" }

	if mute.mic then
		mic.color = "#948D60"
		mic.icon = '&#xF131;'
	end

	if mute.speaker then
		spkr.color = "#948D60"
		spkr.icon = '&#xF026;'
	end

	w.icon:set_markup(color(mic.color, mic.icon) .." ".. color(spkr.color, spkr.icon))
	w.data:set_markup(color(spkr.color, string.format('%3d', val)))
end
widget.volume.worker = mods.pulse(widget.volume.func, 5)

-- Battery 
widget.battery = {} 
widget.battery.icon = wibox.widget.textbox('&#xF0E7;')
widget.battery.icon:set_font(theme.font_icon .. ' ' .. (theme.font_size + 2))
widget.battery.data = wibox.widget.textbox()
widget.battery.func = function(w, d)
	local w = my.widget.battery
	local p = tonumber(bat_now.perc)
	local s = bat_now.status == "Charged" and 'F' or bat_now.status:sub(1,1)

	local critical = 10
	local low = 30

	local icon = (s == 'C' or s == 'F') and '&#xF0E7;' or
				 p > 75 and '&#xF240;' or
				 p > 50 and '&#xF241;' or
				 p > 25 and '&#xF242;' or
				 p > 5  and '&#xF243;' or '&#xF244;'

	local col = (s == 'C' or s == 'F') and '#00CCCC' or
				p > low and '#03cc00' or 
				p > critical and '#FBE72A' or '#FB6B24'

	w.icon:set_markup(color(col, string.format('%s', icon)))
	w.data:set_markup(color(col, string.format('%3d', p)))
	return
end
widget.battery.worker = lain.widgets.bat({ timeout = 5, settings = widget.battery.func })

-- Wifi
widget.wifi = {}
widget.wifi.icon = wibox.widget.textbox(color('DarkCyan', '&#xF1EB;'))
widget.wifi.icon:set_font(theme.font_icon .. ' ' .. (theme.font_size + 2))
widget.wifi.data =  wibox.widget.textbox()
widget.wifi.tip = awful.tooltip({
	objects = { widget.wifi.icon, widget.wifi.data },
	timer_function = function()
		return color('DarkCyan', string.format('%s', widget.wifi.tipdata))
	end,
})
widget.wifi.func = function(w, data)
	local s = data['{ssid}'].."\n"
--	s = s.."Channel: "..data['{chan}'].."\n"
	s = s.."Bit rate: "..data['{rate}'].." MB/s"
	widget.wifi.tipdata = s

	if data['{linp}'] > 0 then
		return color('DarkCyan', markup.monospace(string.format('%3.0f', data['{linp}'])))
	else
		return ""
	end
end
vicious.register(widget.wifi.data, vicious.widgets.wifi, widget.wifi.func, 2, 'wl')


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
local rules = {
	{ rule = { class = "Chromium" },					properties = { tag = tags[1][2] } },
	{ rule = { class = "Firefox" },						properties = { tag = tags[1][2] } },
	{ rule = { class = "URxvt", instance = "irssi" },	properties = { tag = tags[1][3] } },
	{ rule = { class = "URxvt", instance = "weechat" },	properties = { tag = tags[1][3] } },
	{ rule = { class = "Steam" },						properties = { tag = tags[1][6] } },
--	{ rule_any = { class = { "mplayer2", "mplayer", "mpv" }},	properties = { tag = tags[1][5] } },
}
awful.rules.rules = awful.util.table.join(awful.rules.rules, require("rules"), rules)
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

-- Common button
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
----

-- ########################################
-- ## Main screen
-- ########################################
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
	left:add(widget.spacer.h)
	left:add(wibox.widget.systray())
	left:add(monitor.main.prompt)
	left = wibox.widget.background(wibox.layout.margin(left,0,4))

	local right = wibox.layout.fixed.horizontal()
	right:add(widget.network)
	right:add(widget.spacer.h)
	right:add(widget.wifi.icon)
	right:add(widget.wifi.data)
	right:add(widget.spacer.h)
	right:add(widget.battery.icon)
	right:add(widget.battery.data)
	right:add(widget.spacer.h)
	right:add(widget.volume.icon)
	right:add(widget.volume.data)
	right:add(widget.spacer.h)
	right:add(widget.clock)
	right:add(widget.spacer.h)
	right = wibox.widget.background(wibox.layout.margin(right,4,4))

	local layout = wibox.layout.align.horizontal(left, monitor.main.tasklist, right)

	monitor.main.bar = awful.wibox({ position = "top", screen = s })
	monitor.main.bar:set_bg(beautiful.bg_bg)
	monitor.main.bar:set_widget(layout)
end

-- ########################################
-- ## Futher screens
-- ########################################

for s = 2, screen.count() do
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
