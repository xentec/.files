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

naughty.config.presets.warning = 
{
	bg = "#ffaa00",
	fg = "#ffffff",
	timeout = 10,
}

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

	mpd_host = "keeper",
}

my.editor_cmd = my.terminal .. " -e " .. my.editor

-- Set the terminal for applications that require it
menubar.utils.terminal = my.terminal
mods.autostart.terminal = my.terminal

beautiful.init(my.theme)
mods.wallpaper.add(my.wallpapers)
mods.autostart.add(my.autostart)

mods.autostart.addXDG()

monitor = { main = 1 }

-- Table of layouts to cover with awful.layout.inc, order matters.
local awm = awful.layout.suit
local ln = lain.layout
layouts =
{
	ln.uselesstile,
	awm.tile,
	awm.fair,
	awm.fair.horizontal,
	ln.uselessfair,
	ln.centerwork,
	awm.floating
}

-- Tags
my.tags = {}
local tags = my.tags

tags[1] = awful.tag({ "main", "web", "chat", "code", "media", "other" }, 1, layouts[1])
for s = 2, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
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
-- ▄▄▄▄▄                      
-- █    █  ▄▄▄    ▄ ▄▄   ▄▄▄  
-- █▄▄▄▄▀ ▀   █   █▀  ▀ █   ▀ 
-- █    █ ▄▀▀▀█   █      ▀▀▀▄ 
-- █▄▄▄▄▀ ▀▄▄▀█   █     ▀▄▄▄▀ 
--                            
-- ########################################

my.bar = {}
local bar = my.bar

bar.main = {}
bar.main = {}
bar.main.prompt = {}
bar.main.taglist = {}
bar.main.taglist.buttons = awful.util.table.join(
						awful.button({ }, 1, awful.tag.viewonly),
						awful.button({ modkey }, 1, awful.client.movetotag),
						awful.button({ }, 3, awful.tag.viewtoggle),
						awful.button({ modkey }, 3, awful.client.toggletag),
						awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
						awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
					)
bar.main.tasklist = {}
bar.main.tasklist.buttons = 
	awful.util.table.join(
		awful.button({ }, 1, function(c)
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
		 awful.button({ }, 3, function()
			if instance then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ width=250 })
			end
		end),
		awful.button({ }, 4, function()
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		end),
		awful.button({ }, 5, function()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end)
	)

bar.main.layout_buttons = 
	awful.util.table.join(
		awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
		awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function() awful.layout.inc(layouts, 1) end),
		awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)
	)


-- ########################################
-- ## Main screen
-- ########################################
do
	bar.main.prompt[monitor.main] = awful.widget.prompt()

	widget.layoutbox[monitor.main] = awful.widget.layoutbox(monitor.main)
	widget.layoutbox[monitor.main]:buttons(bar.main.layout_buttons)

	bar.main.taglist[monitor.main] = awful.widget.taglist(monitor.main, awful.widget.taglist.filter.all, bar.main.taglist.buttons)
	bar.main.tasklist[monitor.main] = awful.widget.tasklist(monitor.main, awful.widget.tasklist.filter.currenttags, bar.main.tasklist.buttons)

	local left = wibox.layout.fixed.horizontal()
	left:add(bar.main.taglist[monitor.main])
	left:add(wibox.widget.systray())
	left:add(bar.main.prompt[monitor.main])
	left = wibox.widget.background(wibox.layout.margin(left,0,4), beautiful.bg_normal)

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
	right:add(widget.layoutbox[monitor.main])
	right = wibox.widget.background(wibox.layout.margin(right,4,4), beautiful.bg_normal)

	local layout = wibox.layout.align.horizontal()
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


-- ########################################
-- ▄    ▄   ▀                 
-- ██  ██ ▄▄▄     ▄▄▄    ▄▄▄  
-- █ ██ █   █    █   ▀  █▀  ▀ 
-- █ ▀▀ █   █     ▀▀▀▄  █     
-- █    █ ▄▄█▄▄  ▀▄▄▄▀  ▀█▄▄▀  
-- 
-- ########################################

root.keys(keys.global)

-- Rules
awful.rules.rules = awful.util.table.join(awful.rules.rules, require("rules"))
local rules = {
	{ rule = { class = "Chromium" },					properties = { tag = tags[1][2] } },
	{ rule = { class = "Firefox" },						properties = { tag = tags[1][2] } },
	{ rule = { class = "URxvt", instance = "irssi" },	properties = { tag = tags[1][3] } },
	{ rule = { class = "URxvt", instance = "weechat" },	properties = { tag = tags[1][3] } },
	{ rule = { class = "Steam" },						properties = { tag = tags[1][6] } },
--	{ rule_any = { class = { "mplayer2", "mplayer", "mpv" }},	properties = { tag = tags[1][5] } },
}
awful.rules.rules = awful.util.table.join(awful.rules.rules, rules)


-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)
		-- Enable sloppy focus
		c:connect_signal("mouse::enter", 
			function(c)
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

mods.wallpaper.init()
mods.autostart.launch()