-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local keys = require("keys")
local pulse = require("pulse")
local common = require("common")
local autostart = require("autostart")

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

				naughty.notify({ preset = naughty.config.presets.critical,
												 title = "Oops, an error happened!",
												 text = err })
				in_error = false
		end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/xentec/.config/awesome/theme.lua")

browser = "firefox"
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

mainscreen = 1

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
tags[1] = awful.tag({"main", "web", "chat", "code", "media", "other"}, 1, layouts[1])
for s = 2, screen.count() do
		-- Each screen has its own tag table.
		tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- ########################################
-- ## Bars
-- ########################################

bar = {}
bar.main = {}
bar.main.wibox = {}
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

-- ## bar.info
-- Create a wibox for each screen and add it
bar.info = {}
bar.info.wibox = {}

-- ########################################
-- ## Widgets
-- ########################################

local widget = {}
widget.spacer = {}
widget.spacer.h = wibox.widget.textbox('<span color="gray"> ┆ </span>')
widget.spacer.v = wibox.widget.textbox('<span color="gray"> ┄ </span>')

-- Layout
widget.layoutbox = {}

-- Clock
widget.clock = awful.widget.textclock('%H:%M %d.%m.%y')

--Battery 
widget.battery = awful.widget.progressbar({ width = 5, height = 60 })
widget.battery:set_vertical(true)
widget.battery:set_background_color("#00AAAA")
widget.battery.warning = {}
vicious.register(widget.battery, vicious.widgets.bat, function(w, data)
	local low = 40
	local critical = 10
   
--[[	["Full\n"]        = "↯",
        ["Unknown\n"]     = "⌁",
        ["Charged\n"]     = "↯",
        ["Charging\n"]    = "+",
        ["Discharging\n"] = "-"		]]--
	if data[2] < critical and w.warning.critical == nil then
		naughty.notify({ preset = naughty.config.presets.critical,
						 title = "Battery charge is critical!",
						 text = data[2] .. " % remaining. Charge me up!" })
		w.warning.critical = true
	end
	w:set_color(data[1] == '↯' and '#00CCCC' or data[2] > low and '#03cc00' or data[2] > critical and '#FF7B00' or '#EE0000')
	w:set_border_color(data[1] == '+' and '#00CCCC' or data[1] == '-' and data[2] <= critical and '#AA0000' or beautiful.bg_focus)
	w:set_background_color(data[1] == '⌁' and '#AA0000' or beautiful.bg_minimize)
	--naughty.notify({title = data[1], text = data[2]})
	return data[2]
end, 10, 'BAT0')

-- Network
widget.network = wibox.widget.textbox()
--vicious.register(widget.network, vicious.widgets.net, '', 1, 'enp4s0')

-- Volume  
widget.volume = awful.widget.progressbar({ width = 5, height = 60 })
widget.volume:set_background_color(beautiful.bg_minimize)
widget.volume:set_color(beautiful.bg_focus)
--widget.volume:set_width(20)
--widget.volume:set_height(5)
widget.volume:set_ticks(true)
--widget.volume:set_border_color("aqua")
widget.volume:set_max_value(100)

local volume = pulse(function(muted, val)
	if muted then
		widget.volume:set_color("#AA0000")
	else
		widget.volume:set_color(beautiful.bg_focus)
	end
	widget.volume:set_value(val)
	--Rnaughty.notify({title = muted and "Muted" or "Unmuted"})
end)

-- CPU
widget.cpu = awful.widget.graph()
widget.cpu:set_width(50)
widget.cpu:set_background_color("#494B4F")
widget.cpu:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, 
                    {1, "#AECF96" }}})
-- Register widget
vicious.register(widget.cpu, vicious.widgets.cpu, "$1")

-- ########################################
-- ## Main screen
-- ########################################
bar.main.prompt[mainscreen] = awful.widget.prompt()
-- Create an imagebox widget which will contains an icon indicating which layout we're using.
-- We need one layoutbox per screen.
widget.layoutbox[mainscreen] = awful.widget.layoutbox(mainscreen)
widget.layoutbox[mainscreen]:buttons(bar.main.layout_buttons)
-- Create a taglist widget
bar.main.taglist[mainscreen] = awful.widget.taglist(mainscreen, awful.widget.taglist.filter.all, bar.main.taglist.buttons)

-- Create a tasklist widget
-- function tasklist.new(screen, filter, buttons, style, update_function, base_widget)
bar.main.tasklist[mainscreen] = awful.widget.tasklist(mainscreen, awful.widget.tasklist.filter.currenttags, bar.main.tasklist.buttons, nil, bar.main.tasklist.update)

-----------------------------------------------------
-- Create the wibox
bar.main.wibox[mainscreen] = awful.wibox({ position = "top", screen = mainscreen })

-- Widgets that are aligned to the left
local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(bar.main.taglist[mainscreen])
left_layout:add(widget.spacer.h)
left_layout:add(bar.main.prompt[mainscreen])

-- Widgets that are aligned to the right
local right_layout = wibox.layout.fixed.horizontal()
right_layout:add(widget.spacer.h)
right_layout:add(wibox.widget.systray())
right_layout:add(widget.spacer.h)
right_layout:add(widget.clock)
right_layout:add(widget.spacer.h)
right_layout:add(widget.layoutbox[mainscreen])

-- Now bring it all together (with the tasklist in the middle)
local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
layout:set_middle(bar.main.tasklist[mainscreen])
layout:set_right(right_layout)

bar.main.wibox[mainscreen]:set_widget(layout)
-----------------------------------------------------
bar.info.wibox[mainscreen] = awful.wibox({ position = "right", screen = mainscreen })

-- Widgets that are aligned to the right
local v_layout = wibox.layout.fixed.vertical()
v_layout:fill_space(false)

widget.volume:set_vertical(true)

--v_layout:add(wlan)
--v_layout:add(widget.cpu)
v_layout:add(widget.battery)
v_layout:add(widget.spacer.v)
v_layout:add(widget.volume)

--bar.info.wibox[mainscreen]:set_widget(v_layout)
bar.info.wibox[mainscreen]:set_widget(wibox.layout.margin(v_layout,2,2,2,2))
-----------------------------------------------------
-- ########################################
-- ## Futher screens
-- ########################################

for s = 1, screen.count() do
	if s ~= mainscreen then
		-- Create an imagebox widget which will contains an icon indicating which layout we're using.
		-- We need one layoutbox per screen.
		widget.layoutbox[s] = awful.widget.layoutbox(s)
		widget.layoutbox[s]:buttons(bar.main.layout_buttons)
		-- Create a taglist widget
		bar.main.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, bar.main.taglist.buttons)

		-- Create a tasklist widget
		bar.main.tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, bar.main.tasklist.buttons, nil, bar.main.tasklist.update)

		-- Create the wibox
		bar.main.wibox[s] = awful.wibox({ position = "top", screen = s })

		-- Widgets that are aligned to the left
		local left_layout = wibox.layout.fixed.horizontal()
		left_layout:add(bar.main.taglist[s])
		left_layout:add(widget.spacer.h)
		left_layout:add(bar.main.prompt[mainscreen])

		-- Widgets that are aligned to the right
		local right_layout = wibox.layout.fixed.horizontal()
		right_layout:add(widget.clock)
		right_layout:add(widget.layoutbox[s])

		-- Now bring it all together (with the tasklist in the middle)
		local layout = wibox.layout.align.horizontal()
		layout:set_left(left_layout)
		layout:set_middle(bar.main.tasklist[s])
		layout:set_right(right_layout)

		bar.main.wibox[s]:set_widget(layout)
	end
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
		awful.button({ }, 3, function () end),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


clientbuttons = awful.util.table.join(
		awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ modkey }, 1, awful.mouse.client.move),
		awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(keys.global)
-- }}}

-- {{{ Rules
awful.rules.rules = awful.util.table.join(awful.rules.rules, require("rules"))
local rules = {
	{ rule = { class = "Chromium" },					properties = { tag = tags[1][2] } },
	{ rule = { class = "Firefox" },						properties = { tag = tags[1][2] } },
	{ rule = { class = "URxvt", instance = "irssi" },	properties = { tag = tags[1][3] } },
	{ rule = { class = "Steam" },						properties = { tag = tags[1][6] } },
	{ rule_any = { class = { "mplayer2", "mplayer" },	properties = { tag = tags[1][5] } },
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

		local titlebars_enabled = false
		if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
				-- Widgets that are aligned to the left
				local left_layout = wibox.layout.fixed.horizontal()
				left_layout:add(awful.titlebar.widget.iconwidget(c))

				-- Widgets that are aligned to the right
				local right_layout = wibox.layout.fixed.horizontal()
				right_layout:add(awful.titlebar.widget.floatingbutton(c))
				right_layout:add(awful.titlebar.widget.maximizedbutton(c))
				right_layout:add(awful.titlebar.widget.stickybutton(c))
				right_layout:add(awful.titlebar.widget.ontopbutton(c))
				right_layout:add(awful.titlebar.widget.closebutton(c))

				-- The title goes in the middle
				local title = awful.titlebar.widget.titlewidget(c)
				title:buttons(awful.util.table.join(
								awful.button({ }, 1, function()
										client.focus = c
										c:raise()
										awful.mouse.client.move(c)
								end),
								awful.button({ }, 3, function()
										client.focus = c
										c:raise()
										awful.mouse.client.resize(c)
								end)
								))

				-- Now bring it all together
				local layout = wibox.layout.align.horizontal()
				layout:set_left(left_layout)
				layout:set_right(right_layout)
				layout:set_middle(title)

				awful.titlebar(c):set_widget(layout)
		end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart
autostart.add({
		"pulseaudio --start",
		"nitrogen --restore",
		{"dropboxd","dropbox"},
		{"irssi", term = true},
	})
autostart.launch()
-- }}}

