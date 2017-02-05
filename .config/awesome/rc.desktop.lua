local gears = require("gears")

local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local menubar = require("menubar")

local lain = require("lain")
local vicious = require("vicious")

local keys = require("keys")
local mods = require("modules")
local private = require("private")

require("awful.autofocus")
-- Override
-- nothing here (yet)

-- Short cuts
local markup = lain.util.markup
local color = markup.fg.color
local dpi = beautiful.xresources.apply_dpi

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

local awmL = awful.layout.layouts
local lnL = lain.layout

-- Variable definitions
my = 
{
	theme = awful.util.get_configuration_dir() .. "theme.lua",

	browser = "chromium",
	terminal = "urxvtc",
	editor = "subl3",

	wallpapers = "~/lold/wg",
	autostart = {
		"QSyncthingTray",
--		{"dropboxd","dropbox"},
		{"steam-native", "steam"},
--		{"weechat", term = true},
--		"skype",
		"utox",
		"compton",
		"hexchat",
		"task sync",
	},
	monitor = { 
		main =
		{
			i = 1,
			--dpi = 158
			dpi = 158,
			tags = { 
				names = { "main", "web", "code", "script", "media", "gaming", "other" },
				layout = 1
			}
		}, 
		info = {
			i = 3,
			--dpi = 94
			dpi = 96,
			tags = 	{
				names = { "chat", "media", "vm" }, 
				layout = 2
			}
		} 
	},
	layout = awmL,
	mpd = {
		host = "keeper",
		music_dir = "/mnt/fridge/music",
	},
}

my.monitor._lk = {
	['DP-0'] = "main",
	['HDMI-0'] = "info",
}

beautiful.init(my.theme)
beautiful.xresources.set_dpi(my.monitor.main.dpi, my.monitor.main.i)
beautiful.xresources.set_dpi(my.monitor.info.dpi, my.monitor.info.i)

-- Notifications 
naughty.config.defaults.opacity = 0.8
naughty.config.defaults.screen = 1
naughty.config.defaults.fg = beautiful.fg_normal:sub(1,7)
naughty.config.defaults.bg = beautiful.bg_normal:sub(1,7)

naughty.config.presets.warning = {
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
-- Set the terminal for applications that require it
menubar.utils.terminal = my.terminal
mods.autostart.terminal = my.terminal

mods.wallpaper.add(my.wallpapers)
mods.wallpaper.launch()

mods.autostart.add(my.autostart)
mods.autostart.launch()

function wibar_default_size(s)
	return math.ceil(beautiful.get_font_height() / beautiful.xresources.get_dpi() * beautiful.xresources.get_dpi(s) * 1.5)
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
widget.def.barLen = 80

widget.spacer = {}
widget.spacer.h = wibox.widget.textbox(color('gray', ' ┆ '))
widget.spacer.v = wibox.widget.textbox(color('gray', ' ┄'))

-- Layout
widget.layoutbox = {}

-- Clock
widget.clock = wibox.widget.textclock('%H:%M %a %d.%m.%y')
-- Calendar
widget.calendar = lain.widgets.calendar({ font = beautiful.font_mono, attach_to = {widget.clock} })
-- Task
--lain.widgets.contrib.task:attach(widget.clock)

-- Mail
widget.mail = lain.widgets.imap({
	timeout = 60,
	server = private.mail.server,
	mail = private.mail.user, 
	password = 'keyring get '..private.mail.server..' '..private.mail.user,
	settings = function()
		local w = my.widget.mail.widget

		if mailcount > 0 then
			w:set_markup('&#xf0e0; '..mailcount)
		else
			w:set_markup('&#xf003;')
		end
	end
})
--widget.mail:set_font(theme.font_icon .. ' ' .. (theme.font_size))

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
widget.volume = wibox.widget.progressbar()
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
	widget.cpu[i] = wibox.widget.progressbar()
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
widget.cpu.temp = wibox.widget.textbox();
widget.cpu.temp.func = function(w, data)
	return color("#876333", markup.monospace(' '..string.format("%.0f", data[1])..'°C'));
end
vicious.register(widget.cpu.temp, mods.thermal, widget.cpu.temp.func, 2, {'hwmon0', 'hwmon'})

-- Memory
widget.mem = {}
widget.mem.ram = wibox.widget.progressbar({ forced_width = widget.def.barLen, forced_height = 8 })
widget.mem.ram:set_background_color("#3A6D8A")
widget.mem.ram:set_color("#269CDF")
widget.mem.swap = wibox.widget.progressbar({ forced_width = widget.def.barLen, forced_height = 8 })
widget.mem.swap:set_background_color("#3A6D8A")
widget.mem.swap:set_color("#269CDF")
widget.mem.func = function()
	my.widget.mem.ram:set_value(mem_now.used/mem_now.total)
	my.widget.mem.swap:set_value(mem_now.swapused/(mem_now.swap or 1))
end
widget.mem.worker = lain.widgets.mem({ settings = widget.mem.func })

-- GPU
widget.gpu = {}
widget.gpu.gl = wibox.widget.progressbar({ forced_width = widget.def.barLen/2, forced_height = 8 })
widget.gpu.gl:set_background_color("#4F8A3A")
widget.gpu.gl:set_color("#3FC51E")

widget.gpu.vl = wibox.widget.progressbar({ forced_width = widget.def.barLen/2, forced_height = 4 })
widget.gpu.vl:set_background_color("#40702F")
widget.gpu.vl:set_color("#3FC51E")

widget.gpu.pcie = wibox.widget.progressbar({ forced_width = widget.def.barLen/2, forced_height = 4 })
widget.gpu.pcie:set_background_color("#40702F")
widget.gpu.pcie:set_color("#3FC51E")

widget.gpu.mem = wibox.widget.progressbar({ forced_width = widget.def.barLen, forced_height = 8 })
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
--mods.gpu({ settings = widget.gpu.func })

-- MPD
widget.mpd = {}
widget.mpd.icon = wibox.widget.textbox()
widget.mpd.icon:set_font(theme.font_icon .. ' ' .. (theme.font_size + 2))
widget.mpd.nfo = wibox.widget.textbox()
widget.mpd.nfo:set_font(theme.font_name .. ' ' .. (theme.font_size - 2))
widget.mpd.bar = wibox.widget.progressbar()
widget.mpd.bar:set_background_color("#716D40")
widget.mpd.bar:set_color("#BDB76B")
widget.mpd.bar:set_ticks_gap(10)
widget.mpd.bar:set_ticks_size(10)
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

		if d.elapsed ~= "N/A" then
			if d.time ~= "N/A" then
				time = tonumber(d.elapsed)/tonumber(d.time)
				w.bar:set_ticks(false)
			else
				time = 1
				w.bar:set_ticks(true)
			end
		end
	else
		w.icon:set_markup(color('#716D40', state.stop));
	end

	w.nfo:set_markup(color('#BDB76B', nfo))
	w.bar:set_value(time)
end
widget.mpd.worker = lain.widgets.mpd({
	timeout = 2,
	host = my.mpd.host,
	music_dir = my.mpd.music_dir,
	cover_size = dpi(100),
	settings = widget.mpd.func,
})

-- Task
widget.task = {}
widget.task.wb = wibox{ type = "desktop" }

widget.task.w = awful.widget.watch('task next', 10,
	function (w, stdout, stderr, er, ec)
		local lines = {}
		for line in stdout:gmatch("[^\r\n]+") do
			if line:len() ~= 0 then
				table.insert(lines, line)
			end
		end
		w:set_text(table.concat(lines, "\n"))
	end)

widget.task.w:set_font(theme.font_mono..' '..theme.font_size)
widget.task.w.valign = "top"
widget.task.w.ellipsize = "end"
widget.task.wb.border_width = 2

do
	local m = dpi(4, screen.primary)
	widget.task.wb:set_widget(wibox.container.margin(widget.task.w, m, m, m, m))
end

widget.task.wb.height = dpi(300, screen.primary) --height = 100, width = 200, visible = true 
widget.task.wb.width = dpi(700, screen.primary)
widget.task.wb.x = screen.primary.workarea.x + screen.primary.workarea.width - widget.task.wb.width - dpi(40, screen.primary)
widget.task.wb.y = screen.primary.workarea.y + dpi(40, screen.primary)
widget.task.wb.visible = true

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
	{ rule = { class = "Chromium" },					properties = { screen = screen.primary, tag = "web" } },
	{ rule = { class = "Firefox" },						properties = { screen = screen.primary, tag = "web" } },
	{ rule = { class = "Steam" },						properties = { screen = screen.primary, tag = "gaming" },
		callback = function(c)
			if c.name and c.name:find("Chat",1,true) then
				awful.rules.execute(c, { floating = false, screen = my.monitor.info.i, tag = "chat" })
			end
		end
	},
	{ rule = { class = "URxvt", instance = "irssi" },	properties = { screen = my.monitor.info.i, tag = "chat" } },
	{ rule = { class = "URxvt", instance = "weechat" },	properties = { screen = my.monitor.info.i, tag = "chat" } },
	{ rule = { class = "Skype" },						properties = { screen = my.monitor.info.i, tag = "chat" } },
	{ rule = { class = "Pidgin" },						properties = { screen = my.monitor.info.i, tag = "chat" } },
	{ rule = { class = "utox" },						properties = { screen = my.monitor.info.i, tag = "chat" } },
	{ rule = { class = "Hexchat" },						properties = { screen = my.monitor.info.i, tag = "chat" } },
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

function setupUnknownScreen(scr)

	-- Create the tags
	awful.tag({ "1", "2", "3", "4" }, scr, my.layout[1])

	scr.prompt = awful.widget.prompt()

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	scr.layoutbox = awful.widget.layoutbox(scr)
	scr.layoutbox:buttons(buttons.layoutbox)
	-- Create a taglist widget
	scr.taglist = awful.widget.taglist(scr, awful.widget.taglist.filter.all, buttons.taglist)
	-- Create a tasklist widget
	scr.tasklist = awful.widget.tasklist(scr, awful.widget.tasklist.filter.currenttags, buttons.tasklist)

	-- Create the wibox
	scr.bar = awful.wibar({ position = "top", screen = scr, height = wibar_default_size(scr) })
	scr.bar:setup
	{
		layout = wibox.layout.align.horizontal,
		{
			-- Widgets that are aligned to the left
			layout = wibox.layout.fixed.horizontal,
			scr.layoutbox,
			widget.spacer.h,
			scr.taglist,
			widget.spacer.h,
			scr.prompt,
		},
		scr.tasklist,
		{
			-- Widgets that are aligned to the right
			layout = wibox.layout.fixed.horizontal,
			widget.spacer.h,
			widget.clock,
		},
	}
end


-- ########################################
-- ## Screens
-- ########################################

awful.screen.connect_for_each_screen(function(scr)

local montype = ""

-- Main ###################################
if scr.index == monitor.main.i then

	montype = "main"

	if monitor.main.tags then
		awful.tag(monitor.main.tags.names, scr, my.layout[monitor.main.tags.layout])
	end

	scr.prompt = awful.widget.prompt()
	
	scr.layoutbox = awful.widget.layoutbox(scr)
	scr.layoutbox:buttons(buttons.layoutbox)

	scr.taglist = awful.widget.taglist(scr, awful.widget.taglist.filter.all, buttons.taglist)
	scr.tasklist = awful.widget.tasklist(scr, awful.widget.tasklist.filter.currenttags, buttons.tasklist)

	scr.bar = awful.wibar({ position = "top", screen = scr, height = wibar_default_size(scr) })
	scr.bar:setup 
	{
		layout = wibox.layout.align.horizontal,
		{ -- Left
			layout = wibox.layout.fixed.horizontal,
			scr.layoutbox,
			widget.spacer.h,
			scr.taglist,
			widget.spacer.h,
			scr.prompt,
		},
		scr.tasklist, -- Middle
		{ -- Right
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			widget.spacer.h,
			widget.mail,
			widget.spacer.h,
			widget.kbd,
			widget.spacer.h,
			widget.clock,
		}
	}

-- Info ###################################
elseif scr.index == monitor.info.i then

	montype = "info"

	if monitor.info.tags then
		awful.tag(monitor.info.tags.names, scr, my.layout[monitor.info.tags.layout])
	end

	scr.prompt = awful.widget.prompt()

	scr.layoutbox = awful.widget.layoutbox(scr)
	scr.layoutbox:buttons(buttons.layoutbox)

	scr.taglist = awful.widget.taglist(scr, awful.widget.taglist.filter.all, buttons.taglist)
	scr.tasklist = awful.widget.tasklist(scr, awful.widget.tasklist.filter.currenttags, buttons.tasklist)

	scr.bar = {}
	scr.bar.top = awful.wibar({ position = "top", screen = scr, height = wibar_default_size(scr) })
	scr.bar.top:setup 
	{
		layout = wibox.layout.align.horizontal,
		{ -- Left
			layout = wibox.layout.fixed.horizontal(),
			scr.layoutbox,
			widget.spacer.h,
			scr.taglist,
			widget.spacer.h,
			scr.prompt,
		},
		scr.tasklist, -- Middle
		{ -- Right
			layout = wibox.layout.fixed.horizontal(),
			widget.spacer.h,
			widget.clock,
		}
	}

--=======================================================

	local cpu = wibox.layout.fixed.vertical()
	for i=1,widget.cpu.count do
		cpu:add(wibox.container.constraint(widget.cpu[i], 'max', nil, 2))
	end

	scr.bar.bottom = awful.wibar({ position = "bottom", screen = scr, height = wibar_default_size(scr) })
	scr.bar.bottom:set_bg("#AA0000")
--	scr.bar.bottom:set_bg(beautiful.bg_normal:sub(1,7) .. "00")
	scr.bar.bottom:setup
	{
		layout = wibox.layout.align.horizontal, 
		{
			-- left
			widget = wibox.container.background, bg = beautiful.bg_normal,
			{
				widget = wibox.container.margin, left = 4, right = 4,
				{
					layout = wibox.layout.fixed.horizontal,			
					{
						id = "cpu",
						layout = wibox.layout.fixed.horizontal,
						{
							widget = wibox.container.constraint,
							width = widget.def.barLen,
							{
								layout = wibox.container.margin, top = 4, bottom = 4,
								cpu,
							}
						},
						widget.cpu.temp,
					},
					widget.spacer.h,
					{
						id = "mem",
						widget = wibox.container.margin, top = 4, bottom = 4,
						{
							widget = wibox.container.constraint,
							width = widget.def.barLen,
							{
								layout = wibox.layout.fixed.vertical,
								widget.mem.ram,
								widget.mem.swap,
							}
						}
					},
					widget.spacer.h,
					{
						id = "gpu",
						layout = wibox.layout.fixed.horizontal,
						{
							widget = wibox.container.margin, top = 4, bottom = 4,
							{
								widget = wibox.container.constraint,
								width = widget.def.barLen,
								{
									layout = wibox.layout.fixed.vertical,
									{
										layout = wibox.layout.fixed.horizontal,
										widget.gpu.gl,
										{
											layout = wibox.layout.fixed.vertical,
											widget.gpu.vl,
											widget.gpu.pcie,
										},
									},
									widget.gpu.mem
								}
							},
						},
						widget.gpu.temp,
					},
					widget.spacer.h,
					widget.network,
				}
			}
		},
		nil,
		{
			-- right
			widget = wibox.container.background, bg = beautiful.bg_normal,
			{
				widget = wibox.container.margin, left = 4, right = 4, top = 4, bottom = 4,
				{
					layout = wibox.layout.fixed.horizontal,
					{
						widget = wibox.container.constraint,
						strategy = "max",
						width = 600,
						{
							id = "mpd",
							layout = wibox.layout.fixed.horizontal,
							{
								widget = wibox.container.margin,
								left = 2, right = 2,
								widget.mpd.icon
							},
							{
								widget = wibox.container.margin,
								left = 2,
								{
									layout = wibox.layout.fixed.vertical,
									widget.mpd.nfo,
									widget.mpd.bar,
								}
							},

						}
					},
					widget.spacer.h,
					{
						id = "volume",
						widget = wibox.container.constraint,
						width = widget.def.barLen,
						widget.volume
					}
				}
			}
		}
	}


-- Further screens ########################
else
	montype = "ex"

	setupUnknownScreen(scr)
end

if scr.outputs then
	naughty.notify{screen = scr, title = "Monitor #"..scr.index.." @ "..tostring(next(scr.outputs)), text = montype, timeout = 10}
end


end)
