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
local private = require("private")

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
	theme = awful.util.get_configuration_dir() .. "theme.lua",

	browser = "chromium",
	terminal = "urxvtc",
	editor = os.getenv("EDITOR") or "vim",

	wallpapers = "~/lold/wg",
	autostart = {
--		{"dropboxd","dropbox"},
--		{"weechat", term = true},
		"urxvtd"
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
		music_dir = os.getenv("HOME") .. "/music"
	},
	tags = {}
}

my.tags = {
	{
		names = { "main", "web", "chat", "code", "media" },
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
mods.wallpaper.launch()

mods.autostart.add(my.autostart)
mods.autostart.launch()


naughty.config.presets.warning = 
{
	bg = "#ffaa00",
	fg = "#ffffff",
	timeout = 10,
}
table.insert(naughty.dbus.config.mapping,
	{{appname = "Discord Canary"},
	{
		bg = "#7289da",
		fg = "#ffffff",
		icon_size = 32,
		timeout = 10, 
	}}
)
naughty.config.notify_callback = function (a)
	if a.dont then return a end
	--naughty.notify({ title = "Notify args", text = gears.debug.dump_return(a, ""), timeout = 0, dont = true })
	return a
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
widget.spacer.h = wibox.widget.textbox(color('gray', '┆'))
widget.spacer.v = wibox.widget.textbox(color('gray', '┄'))

for k,w in pairs(widget.spacer) do
	w.align = "center"
end

-- Layout
widget.layoutbox = {}

-- Clock
widget.clock = awful.widget.textclock('%H:%M %a %d.%m.%y ')
-- Calendar
lain.widgets.calendar.attach(widget.clock, { font = beautiful.font_mono })

--[[ Mail
widget.mail = lain.widgets.imap({
	timeout = 60,
	server = private.mail.server,
	mail = private.mail.user, 
	password = 'keyring get '..private.mail.server..' '..private.mail.user,
	settings = function()
		local w = my.widget.mail

		if mailcount > 0 then
			w:set_markup('&#xf0e0; '..mailcount)
		else
			w:set_markup('&#xf003;')
		end
	end
})
widget.mail:set_font(theme.font_icon .. ' ' .. (theme.font_size))
--]]

-- Network
widget.network = {}
widget.network.data = wibox.widget.textbox()
widget.network.data:set_font(theme.font_name .. ' ' .. (theme.font_size - 2))

widget.network.func = 
	function()
		local function humanBytes(bytes)
			local unit = {"K", "M", "G", "T", "P", "E"}
			local i = 1
			bytes = tonumber(bytes)
			while bytes > 99 do
				bytes = bytes / 1024
				i = i+1
			end
			return bytes, unit[i]
		end

		local w = my.widget.network.data

		if net_now.carrier == '1'
		then
			local down, down_suf = humanBytes(net_now.received);
			local up, up_suf = humanBytes(net_now.sent);

			w:set_markup(color("DodgerBlue", string.format('↓ %s\n%.1f\n↑ %s\n%.1f', down_suf, down, up_suf, up)))
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
widget.volume.func = function(mute, val)
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

	w.icon:set_markup(color(mic.color, mic.icon) .."\n".. color(spkr.color, spkr.icon))
	w.data:set_markup(color(spkr.color, string.format('%d', val)))
end
widget.volume.worker = mods.pulse(widget.volume.func, 5)

-- MPD
widget.mpd = {}
widget.mpd.icon = wibox.widget.textbox()
widget.mpd.icon:set_font(theme.font_icon .. ' ' .. (theme.font_size - 2))
widget.mpd.bar = awful.widget.progressbar()
widget.mpd.bar:set_background_color("#716D40")
widget.mpd.bar:set_color("#BDB76B")
do
	local w,h = widget.mpd.icon:get_preferred_size()
	--widget.mpd.bar.forced_width = w + w/2
end

widget.mpd.tip = awful.tooltip({})
widget.mpd.func = function()
	local d = mpd_now;
	local w = my.widget.mpd;

	local nfo = ""
	local time = 0
	local states = {
		play = '&#xF04B;',
		pause = '&#xF04C;',
		stop = '&#xF04D;'
	}

	if states[d.state] == nil then
		w.icon:set_markup(color('#716D40', states.stop));
		d.state = 'stop'
	else
		w.icon:set_markup(color('#BDB76B', states[d.state]));

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
	end

	if d.state == 'stop' then
		widget.mpd.tip:remove_from_object(widget.mpd.icon)
		widget.mpd.tip:remove_from_object(widget.mpd.bar)
	else
		widget.mpd.tip:add_to_object(widget.mpd.icon)
		widget.mpd.tip:add_to_object(widget.mpd.bar)
	end

	local function dur(time)
		if(time == nil) then
			return ""
		end
		return string.format("%.0f:%02d", math.floor(time / 60), time % 60)
	end

--	w.bar:set_width(nfo:len())
	nfo = color('#BDB76B', nfo);
--	w.nfo:set_markup(nfo)
	w.tip:set_markup(nfo.." "..dur(tonumber(d.elapsed)).." / "..dur(tonumber(d.time)))
	w.bar:set_value(time)
end
widget.mpd.worker = lain.widgets.mpd({
	timeout = 1,
	host = my.mpd.host,
	music_dir = my.mpd.music_dir,
	settings = widget.mpd.func,
})

-- Battery 
widget.battery = {} 
widget.battery.icon = wibox.widget.textbox('&#xF0E7;')
widget.battery.icon:set_font(theme.font_icon .. ' ' .. (theme.font_size + 2))
widget.battery.data = wibox.widget.textbox()
widget.battery.tip = awful.tooltip({ objects = { widget.battery.icon, widget.battery.data } })
widget.battery.func = function(w, d)
	local w = my.widget.battery
	local p = tonumber(bat_now.perc)
	local s = bat_now.status == "Charged" and 'F' or bat_now.status:sub(1,1)
	if s == nil or p == nil then return end

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

	w.icon:set_markup(color(col, icon))
	w.data:set_markup(color(col, string.format('%d', p)))

	w.tip:set_markup(color(col, bat_now.watt.." W - "..bat_now.time))
	return
end
widget.battery.worker = lain.widgets.bat({ timeout = 5, settings = widget.battery.func })

-- Wifi
widget.wifi = {}
widget.wifi.icon = wibox.widget.textbox(color('DarkCyan', '&#xF1EB;'))
widget.wifi.icon:set_font(theme.font_icon .. ' ' .. (theme.font_size + 2))
widget.wifi.data = wibox.widget.textbox()
widget.wifi.tip = awful.tooltip({ objects = { widget.wifi.icon, widget.wifi.data } })
widget.wifi.func = function(w, data)

	if data['{linp}'] > 0 then
 		w.icon:set_markup(color('DarkCyan', '&#xF1EB;'))
		w.data:set_markup(color('DarkCyan', markup.monospace(string.format('%.0f', data['{linp}']))))
	else
 		w.icon:set_markup(color('Grey', '&#xF1EB;'))
		w.data:set_markup("")
	end

	local s = data['{ssid}'].."\n"
	s = s.."Channel: "..data['{chan}'].."\n"
	s = s.."Bit rate: "..data['{rate}'].." MB/s"
	widget.wifi.tip:set_markup(color('DarkCyan', s)) 

	return ""
end
vicious.register(widget.wifi, vicious.widgets.wifi, widget.wifi.func, 2, 'wl')



-- Task
widget.task = {}
widget.task.w = wibox.widget.textbox()
widget.task.w:set_font(theme.font_mono..' '..theme.font_size)
widget.task.w.valign = "top"
widget.task.w.ellipsize = "end"

widget.task.w = awful.widget.watch('task next', 10,
	function (w, stdout, stderr, er, ec)
		local lines = {}
		for line in stdout:gmatch("[^\r\n]+") do
			if line:len() ~= 0 then
				table.insert(lines, line)
			end
		end
		if widget.task.wb ~= nil then
			widget.task.wb.height = beautiful.get_font_height(w.font) * #lines + 8
		end
		w:set_text(table.concat(lines, "\n"))
	end, widget.task.w)





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
	{ rule = { class = "Chromium" },					properties = { tag = "web" } },
	{ rule = { class = "Firefox" },						properties = { tag = "web" } },
	{ rule = { class = "URxvt", instance = "irssi" },	properties = { tag = "chat" } },
	{ rule = { class = "URxvt", instance = "weechat" },	properties = { tag = "chat" } },
	{ rule = { class = "Steam" },						properties = { tag = "other" } },
--	{ rule_any = { class = { "mplayer2", "mplayer", "mpv" }},	properties = { tag = tags[1][5] } },
}
awful.rules.rules = awful.util.table.join(awful.rules.rules, require("rules"), rules)
----

-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c) 
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- if not awesome.startup then awful.client.setslave(c) end

		if awesome.startup and
			not c.size_hints.user_position
			and not c.size_hints.program_position then
			
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end
	end)

-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
			and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

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
		awful.button({}, 1, function(t) t:view_only() end),
		awful.button({ keys.mod }, 1,  function(t) if client.focus then client.focus:move_to_tag(t) end end),
		awful.button({}, 3, awful.tag.viewtoggle),
		awful.button({ keys.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end)
	),
	tasklist = awful.util.table.join(
		awful.button({}, 1, function(c)
			if c == client.focus then
				c.minimized = true
			else
				-- Without this, the following
				-- :isvisible() makes no sense
				c.minimized = false
				if not c:isvisible() and c.first_tag then
					c.first_tag:view_only()
				end
				-- This will also un-minimize
				-- the client, if needed
				client.focus = c
				c:raise()
			end
		end),
		awful.button({}, 4, function()
			awful.client.focus.byidx(1)
		end),
		awful.button({}, 5, function()
			awful.client.focus.byidx(-1)
		end)
	),
	layoutbox = awful.util.table.join(
		awful.button({}, 1, function() awful.layout.inc(my.layout, 1) end),
		awful.button({}, 3, function() awful.layout.inc(my.layout, -1) end)
	)
}
----

-- ########################################
-- ## Screens
-- ########################################

awful.screen.connect_for_each_screen(function(scr)

if my.tags[scr.index] then
	awful.tag(my.tags[scr.index].names, scr, my.tags[scr.index].layout)
else
	awful.tag({ 1, 2, 3, 4 }, scr, my.layout[1])
end

-- Main ###################################
if scr == screen.primary then

	scr.prompt = awful.widget.prompt()
	
	scr.layoutbox = awful.widget.layoutbox(scr)
	scr.layoutbox:buttons(buttons.layoutbox)

	scr.taglist = awful.widget.taglist(scr, awful.widget.taglist.filter.all, buttons.taglist)
	scr.tasklist = awful.widget.tasklist(scr, awful.widget.tasklist.filter.currenttags, buttons.tasklist)

	scr.bar = {}
	scr.bar.top = awful.wibar({ position = "top", screen = scr})

	scr.bar.top:setup
	{
		layout = wibox.layout.align.horizontal,
		{ -- Left
			layout = wibox.layout.fixed.horizontal,
			scr.layoutbox,
			widget.spacer.h,
			scr.taglist,
			scr.prompt,
			widget.spacer.h,
		},
		scr.tasklist, -- Middle
		{ -- Right
			layout = wibox.layout.fixed.horizontal,
			widget.spacer.h,
			wibox.widget.systray(),
			widget.spacer.h,
			widget.clock,
		}
	}

	scr.bar.info = awful.wibar({ position = "right", screen = scr, width = 26 })

	for k,w in pairs(widget) do
		if w.icon then w.icon.align = "center" end
		if w.data then w.data.align = "center" end
		if w.align then w.align = "center" end

		--naughty.notify{ text = gears.debug.dump_return(w, k, 1), timeout = 0}
	end

	scr.bar.info:setup
	{
		layout = wibox.layout.fixed.vertical,
		widget.mail,
		widget.spacer.v,
		widget.network.data,
		widget.spacer.v,
		widget.wifi.icon,
		widget.wifi.data,
		widget.spacer.v,
		widget.battery.icon,
		widget.battery.data,
		widget.spacer.v,
		widget.mpd.icon,
		{
			widget = wibox.container.margin,
			left = 4,
			right = 4,
			{
				widget = wibox.container.constraint,
				width = 16,
				height = 2,
				widget.mpd.bar,
			}
		},
		widget.spacer.v,
		widget.volume.icon,
		widget.volume.data,
		widget.spacer.v,
		widget.kbd,
	}

	widget.task.wb = wibox{ type = "desktop" }
	widget.task.wb:geometry 
	{
		height = 100, --height = 100, width = 200, visible = true 
		width = 500,
		x = screen.primary.workarea.x + screen.primary.workarea.width - 500 - 20,
		y = screen.primary.workarea.y + 20,
	}
	widget.task.wb.border_width = 2
	widget.task.wb.visible = true
	widget.task.wb:set_widget(wibox.container.margin(widget.task.w, 4, 4, 4, 4))


else

	-- ########################################
	-- ## Futher screens
	-- ########################################

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	scr.layoutbox = awful.widget.layoutbox(scr)
	scr.layoutbox:buttons(buttons.layoutbox)

	-- Create a taglist widget
	scr.taglist = awful.widget.taglist(scr, awful.widget.taglist.filter.all, buttons.taglist)

	-- Create a tasklist widget
	scr.tasklist = awful.widget.tasklist(scr, awful.widget.tasklist.filter.currenttags, buttons.tasklist)

	-- Create the wibox
	scr.bar = awful.wibar({ position = "top", screen = scr })

	scr.bar:setup
	{
		layout = wibox.layout.align.horizontal,
		{ -- Left
			layout = wibox.layout.fixed.horizontal,
			scr.layoutbox,
			widget.spacer.h,
			scr.taglist,
			widget.spacer.h,
		},
		scr.tasklist, -- Middle
		{ -- Right
			layout = wibox.layout.fixed.horizontal,
			widget.spacer.h,
			widget.clock,
		}
	}

	gears.wallpaper.fit("/home/xentec/lold/wg/sehen.sie.nichts.png", scr, "#000000")
end

end)

