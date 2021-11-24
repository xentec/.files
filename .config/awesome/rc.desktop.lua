local gears = require("gears")

local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local menubar = require("menubar")

local lain = require("lain")

local keys = require("keys")
local mods = require("modules")
local lay = require("layout")
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

	browser = "firefox",
	terminal = "alacritty",
	editor = "subl3",

	wallpapers = "~/lold/wg",
	autostart = {
		"QSyncthingTray",
		{"steam-native", "steam"},
--      {"weechat", term = true},
		"picom",
		"hexchat",
		{ "task sync", force = true },
	},
	monitor = {
		main =
		{
			i = 1,
			dpi = 158,
--			dpi = 96,
			tags = {
				names = { "main", "web", "code", "script", "chat", "media", "gaming", "other" },
				layout = 1
			}
		},
		info = {
			i = 2,
			dpi = 96,
			tags =  {
				names = { "irc", "media", "w:mapr", "w:oth", "w:of" },
				layout = 2
			}
		},
		_ex = {
			dpi = 96,
			tags =  {
				names = { "1", "2", "3", "4" },
				layout = 4
			}
		}
	},
	layout = gears.table.join({lay.block, lay.block.horizontal}, awmL, { lnL.termfair }),
	mpd = {
		host = "keeper",
		music_dir = "/mnt/fridge/music",
--        host = "localhost",
--        music_dir = "~/music",
	},
}

my.monitor._lk = {
	['DisplayPort-0'] = "main",
	['HDMI-A-0'] = "info",
}

if screen.count == 1 then
	my.monitor.info.i = my.monitor.main.i
end

beautiful.init(my.theme)

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


naughty.dbus.config.mapping = gears.table.join(naughty.dbus.config.mapping, {
	{{appname = "Discord"},
	{
		bg = "#7289da",
		fg = "#ffffff",
		timeout = 20,
	}},
	{{appname = "Electron"}, --Slack actually
	{
		bg = "#303E4D",
		fg = "#ffffff",
		timeout = 20,
	}},
	{{appname = "ScudCloud"}, --Slack actually
	{
		bg = "#303E4D",
		fg = "#ffffff",
		timeout = 20,
	}},
	{{appname = "fish"},
	{
		bg = "#308F4A",
		fg = "#ffffff",
	}},
})


naughty.config.notify_callback = function(n)
	n.icon_size = 128
	if n.dont then return n end
	--naughty.notify({ title = "Notify args", text = gears.debug.dump_return(n, ""), timeout = 0, dont = true })
	return n
end


-- Set the terminal for applications that require it
menubar.utils.terminal = my.terminal
mods.autostart.terminal = my.terminal

mods.wallpaper.add(my.wallpapers)
mods.wallpaper.launch()

mods.autostart.add(my.autostart)

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
widget.def.barLen = dpi(60)

widget.spacer = {}
widget.spacer.h = wibox.widget.textbox(color('gray', ' ┆ '))
widget.spacer.v = wibox.widget.textbox(color('gray', ' ┄'))

-- Layout
widget.layoutbox = {}

-- Clock
widget.clock = wibox.widget.textclock('%H:%M %a %d.%m.%y')
-- Calendar
widget.calendar = awful.widget.calendar_popup.month()
widget.calendar:attach(widget.clock, "tr")
-- Task
--lain.widget.contrib.task:attach(widget.clock)

-- Mail
--[[widget.mail = lain.widget.imap({
	timeout = 5,
	server = private.mail.server,
	mail = private.mail.user,
	password = 'keyring get '..private.mail.server..' '..private.mail.user,
	settings = function()
		local w = my.widget.mail.widget

		if mailcount > 0 then
			w:set_markup(color('#BDB76B', '<b>&#xF0E0;</b> '..mailcount))
		else
			w:set_markup(color(theme.fg_normal, '&#xF0E0;'))
		end
	end
})
widget.mail.widget:set_font(theme.font_icon .. ' ' .. (theme.font_size))
widget.mail.widget:set_markup('&#xF0E0;')
widget.mail.widget:buttons(awful.button({ }, 1, function() awful.spawn.spawn('xdg-open "https://'..private.mail.server..'"') end))
--widget.mail:set_font(theme.font_icon .. ' ' .. (theme.font_size))
]]

-- Keyboard Layout
widget.kbd = awful.widget.keyboardlayout()

-- Network
widget.network = {}
widget.network.up = wibox.widget.textbox()
--widget.network.up:set_font(theme.font_name .. ' ' .. (theme.font_size - 2))
widget.network.down = wibox.widget.textbox()
--widget.network.down:set_font(theme.font_name .. ' ' .. (theme.font_size - 2))
widget.network.func = function()
		local function humanBytes(bytes)
			local unit = {"K", "M", "G", "T", "P", "E"}
			local i = 1
			bytes = tonumber(bytes)
			while bytes > 1000 do
				bytes = bytes / 1024
				i = i+1
			end
			return bytes, unit[i]
		end

		local w = my.widget.network

		if net_now.devices['enp9s0'].carrier == '1'
		then
			local down, down_suf = humanBytes(net_now.received);
			local up, up_suf = humanBytes(net_now.sent);

			w.up  :set_markup(color("#269CDF", markup.monospace(string.format('↑ %5.1f %s', up, up_suf))))
			w.down:set_markup(color("#269CDF", markup.monospace(string.format('↓ %5.1f %s', down, down_suf))))
		else
			w.up  :set_markup(color("#DF8F26", markup.monospace(' !! ')))
			w.down:set_markup(color("#DF8F26", markup.monospace(' DC ')))
		end
	end
widget.network.worker = lain.widget.net({
	settings = widget.network.func,
	iface = { "enp9s0" },
	eth_state = "on",
})

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
widget.cpu.count = 16
for i = 1,widget.cpu.count do
	widget.cpu[i] = wibox.widget.progressbar()
	widget.cpu[i]:set_background_color("#876333")
	widget.cpu[i]:set_color("#DF8F26")
	widget.cpu[i]:set_ticks(true)
	widget.cpu[i]:set_ticks_size(widget.def.barLen/10-1)
end
widget.cpu.func = function()
	local w = my.widget.cpu
	for i = 1,w.count do
		w[i]:set_value(cpu_now[i-1].usage/100)
	end
end
lain.widget.cpu({ settings = widget.cpu.func })

widget.cpu.temp = wibox.widget.textbox();
widget.cpu.temp:set_font(theme.font_name .. ' ' .. (theme.font_size + 2))
widget.cpu.temp.worker = gears.timer {
	timeout   = 2,
	call_now  = true,
	autostart = true,
	callback  = function()
		local helpers = require("lain.helpers")
		local temp_path = "/sys/class/hwmon/hwmon2/temp4_input"
		local temp = tonumber(helpers.first_line(temp_path)) or 0

		widget.cpu.temp:set_markup(color('#DF8F26', markup.monospace(string.format("%.0f°C", temp/1000))))
	end
}

-- Memory
widget.mem = {}
widget.mem.ram = wibox.widget.progressbar()
widget.mem.ram:set_background_color("#3A6D8A")
widget.mem.ram:set_color("#269CDF")
widget.mem.ram:set_ticks(true)
widget.mem.ram:set_ticks_size(widget.def.barLen/8-1)
widget.mem.ram:set_max_value(100)
widget.mem.func = function()
	my.widget.mem.ram:set_value(mem_now.perc)
	--naughty.notify{ text = tostring(mem_now.perc)}
end
widget.mem.worker = lain.widget.mem({ settings = widget.mem.func })

-- GPU
---[[
widget.gpu = {}
widget.gpu.gl = wibox.widget.progressbar()
widget.gpu.gl:set_background_color("#4F8A3A")
widget.gpu.gl:set_color("#3FC51E")
widget.gpu.vl = wibox.widget.progressbar()
widget.gpu.vl:set_background_color("#40702F")
widget.gpu.vl:set_color("#3FC51E")
widget.gpu.pcie = wibox.widget.progressbar()
widget.gpu.pcie:set_background_color("#40702F")
widget.gpu.pcie:set_color("#3FC51E")
widget.gpu.mem = wibox.widget.progressbar()
widget.gpu.mem:set_background_color("#4F8A3A")
widget.gpu.mem:set_color("#3FC51E")
widget.gpu.mem:set_ticks(true)
widget.gpu.mem:set_ticks_size(widget.def.barLen/8-1)
widget.gpu.temp = wibox.widget.textbox()
widget.gpu.temp:set_font(theme.font_name .. ' ' .. (theme.font_size + 2))
widget.gpu.timer = gears.timer {
	timeout   = 2,
	call_now  = true,
	autostart = true,
	callback  = function()
		local helpers = require("lain.helpers")
		local gpu_path = "/sys/class/graphics/fb0/device/"

		local query_number = function(attr)
			return tonumber(helpers.first_line(gpu_path..attr)) or 0
		end

		local w = widget.gpu
		w.gl:set_value(query_number('gpu_busy_percent')/100.0)
		w.vl:set_value(0)
		w.pcie:set_value(query_number('mem_busy_percent')/100.0)
		w.mem:set_value(query_number('mem_info_vram_used') / query_number('mem_info_vram_total'))
		w.temp:set_markup(color('#3FC51E', markup.monospace(string.format("%.0f°C", query_number('hwmon/hwmon4/temp1_input')/1000))))
	end
}
--]]

-- Storage
---[[
widget.ssd = {}
widget.ssd.usage = {}
widget.ssd.usage.root = wibox.widget.progressbar()
widget.ssd.usage.root:set_background_color("#555555")
widget.ssd.usage.root:set_color("#777777")
widget.ssd.usage.root:set_ticks(true)
widget.ssd.usage.root:set_ticks_size(widget.def.barLen/8-1)
widget.ssd.usage.root:set_max_value(100)
widget.ssd.usage.home = wibox.widget.progressbar()
widget.ssd.usage.home:set_background_color("#555555")
widget.ssd.usage.home:set_color("#777777")
widget.ssd.usage.home:set_ticks(true)
widget.ssd.usage.home:set_ticks_size(widget.def.barLen/8-1)
widget.ssd.usage.home:set_max_value(100)
widget.ssd.temp = wibox.widget.textbox()
widget.ssd.temp:set_font(theme.font_name .. ' ' .. (theme.font_size + 2))
widget.ssd.func = function()
	my.widget.ssd.usage.root:set_value(fs_now["/"].percentage)
	my.widget.ssd.usage.home:set_value(fs_now["/home"].percentage)

	local helpers = require("lain.helpers")
	local path = "/sys/class/nvme/nvme0"

	local query_number = function(attr)
		return tonumber(helpers.first_line(path..attr)) or 0
	end
	my.widget.ssd.temp:set_markup(color('#777777', markup.monospace(string.format("%.0f°C", query_number('/hwmon1/temp1_input')/1000))))
end
widget.ssd.worker = lain.widget.fs({
	settings = widget.ssd.func,
	widget = widget.ssd.usage.root,
	partition = "/",
	timeout = 5,
})



-- MPD
widget.mpd = {}
widget.mpd.icon = wibox.widget.textbox('&#xF04D;')
widget.mpd.icon:set_font(theme.font_icon .. ' ' .. (theme.font_size + 4))
widget.mpd.nfo = wibox.widget.textbox(' ')
widget.mpd.nfo:set_font(theme.font_name .. ' ' .. (theme.font_size))
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
	w.bar.forced_width = w.nfo:get_preferred_size()
end
widget.mpd.worker = lain.widget.mpd({
	timeout = 2,
	host = my.mpd.host,
	music_dir = my.mpd.music_dir,
	cover_size = dpi(100),
	settings = widget.mpd.func,
})


-- Task
widget.task = {}
widget.task.w = wibox.widget.textbox()
widget.task.w:set_font(theme.font_mono..' '..theme.font_size)
widget.task.w.valign = "top"
widget.task.w.ellipsize = "end"

widget.task.wb = wibox{ type = "desktop" }
widget.task.wb.border_width = dpi(2, screen.primary)
widget.task.wb.visible = false
do
	local m = dpi(4, screen.primary)
	widget.task.wb:set_widget(wibox.container.margin(widget.task.w, m, m, m, m))
end

widget.task.w = awful.widget.watch('task next', 10,
	function (w, stdout, stderr, er, ec)
		local lines = {}
		for line in stdout:gmatch("[^\r\n]+") do
			if line:len() ~= 0 then
				table.insert(lines, line)
			end
		end
		w:set_text(table.concat(lines, "\n"))

		local w, h = w:get_preferred_size(screen.primary)
		w = w + dpi(10, screen.primary)
		h = h + dpi(10, screen.primary)
		widget.task.wb:geometry
		{
			height = h,
			width = w,
			x = screen.primary.workarea.x + screen.primary.workarea.width - w - dpi(20, screen.primary),
			y = screen.primary.workarea.y + screen.primary.workarea.height - h - dpi(20, screen.primary),
		}
		widget.task.wb.visible = true
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
local rules =
{
	{ rule = { class = "Chromium" },                    properties = { screen = screen.primary, tag = "web" } },
	{ rule = { class = "Firefox" },                     properties = { screen = screen.primary, tag = "web" } },
	{ rule = { class = "Steam" },                       properties = { screen = screen.primary, tag = "gaming" },
		callback = function(c)
			if c.name and c.name:find("Chat",1,true) then
				awful.rules.execute(c, { floating = false, screen = my.monitor.info.i, tag = "chat" })
			end
		end
	},
	{ rule = { class = "URxvt", instance = "irssi" },   properties = { screen = my.monitor.info.i, tag = "irc" } },
	{ rule = { class = "URxvt", instance = "weechat" }, properties = { screen = my.monitor.info.i, tag = "irc" } },
	{ rule = { class = "Skype" },                       properties = { screen = my.monitor.main.i, tag = "chat" } },
	{ rule = { class = "Pidgin" },                      properties = { screen = my.monitor.main.i, tag = "chat" } },
	{ rule = { class = "Hexchat" },                     properties = { screen = my.monitor.info.i, tag = "irc" } },
	{ rule = { class = "utox" },                        properties = { screen = my.monitor.main.i, tag = "chat" } },
	{ rule = { class = "qTox" },                        properties = { screen = my.monitor.main.i, tag = "chat" } },
	{ rule = { class = "TelegramDesktop" },             properties = { screen = my.monitor.main.i, tag = "chat" } },
	{ rule = { class = "discord" },                     properties = { screen = my.monitor.main.i, tag = "chat" } },
	{ rule = { class = "Slack" },                       properties = { screen = my.monitor.main.i, tag = "chat" } },
	{ rule = { class = "mpv" },                         properties = { screen = my.monitor.main.i } },
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
	taglist = gears.table.join(
		awful.button({}, 1, function(t) t:view_only() end),
		awful.button({ keys.mod }, 1,  function(t) if client.focus then client.focus:move_to_tag(t) end end),
		awful.button({}, 3, awful.tag.viewtoggle),
		awful.button({ keys.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end)
	),
	tasklist = gears.table.join(
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
	layoutbox = gears.table.join(
		awful.button({}, 1, function() awful.layout.inc(my.layout, 1) end),
		awful.button({}, 3, function() awful.layout.inc(my.layout, -1) end)
	)
}


-- ########################################
-- ## Screens
-- ########################################

awful.screen.connect_for_each_screen(function(scr)

	local mon_output = tostring(next(scr.outputs));
	local mon_type = monitor._lk[mon_output] or "_ex"
	local mon_config = monitor[mon_type];

	beautiful.xresources.set_dpi(mon_config.dpi, scr)

	naughty.notify{screen = scr, title = "Monitor #"..scr.index.." @ "..mon_output, text = "dpi: ".. beautiful.xresources.get_dpi(scr) .."\n" .. mon_type, timeout = 100}

	if mon_config.tags then
		awful.tag(mon_config.tags.names, scr, my.layout[mon_config.tags.layout])
	end

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	scr.layoutbox = awful.widget.layoutbox(scr)
	scr.layoutbox:buttons(buttons.layoutbox)
	-- Create a taglist widget
	scr.taglist = awful.widget.taglist(scr, awful.widget.taglist.filter.all, buttons.taglist)
	-- Create a tasklist widget
	scr.tasklist = awful.widget.tasklist(scr, awful.widget.tasklist.filter.currenttags, buttons.tasklist)

	-- Create the wibox
	scr.bar = {}
	scr.bar.top = awful.wibar({ position = "top", screen = scr, height = wibar_default_size(scr) })
	scr.bar.top:setup
	{
		layout = wibox.layout.align.horizontal,
		{
			-- Widgets that are aligned to the left
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(8),
			spacing_widget = wibox.widget.separator,
			scr.layoutbox,
			scr.taglist,
			wibox.widget.base.empty_widget(),
		},
		scr.tasklist,
		widget.clock,
	}

	-- Main ###################################
	if mon_type == "main" then
		scr.bar.top.widget.third = wibox.widget.base.make_widget_declarative
		{ -- Right
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(8),
			spacing_widget = wibox.widget.separator,
			wibox.widget.systray(),
			widget.mail,
			widget.kbd,
			widget.clock,
		}
	end

	-- Info ###################################
	if mon_type == "info" then

		local cpu = wibox.layout.flex.vertical()
		for i=1,widget.cpu.count do
			cpu:add(widget.cpu[i])
		end

		scr.bar.bottom = awful.wibar({ position = "bottom", screen = scr, height = dpi(20) })
	--  scr.bar.bottom:set_bg("#AA0000")
		scr.bar.bottom:set_bg(beautiful.bg_normal:sub(1,7) .. "00")
		scr.bar.bottom:setup
		{
			layout = wibox.layout.align.horizontal,
			{
				-- left
				widget = wibox.container.background, bg = beautiful.bg_normal,
				{
					widget = wibox.container.margin,
					left = dpi(2), right = dpi(2), top = dpi(2), bottom = dpi(2),
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(8),
						spacing_widget = wibox.widget.separator,
						{
							id = "cpu",
							layout = wibox.layout.fixed.horizontal,
							{
								widget = wibox.container.constraint,
								strategy = "max",
								width = widget.def.barLen,
								cpu,
							},
							{
								widget = wibox.container.margin,
								left = dpi(2),
								widget.cpu.temp,
							}
						},
						{
							id = "mem",
							widget = wibox.container.constraint,
							strategy = "max",
							width = widget.def.barLen,
							widget.mem.ram,
						},

						{
							id = "gpu",
							layout = wibox.layout.fixed.horizontal,
							{
--								widget = wibox.container.margin, top = dpi(2), bottom = dpi(2),
--								{
									widget = wibox.container.constraint,
									width = widget.def.barLen,
									{
										layout = wibox.layout.flex.vertical,
--[[									{
											layout = wibox.layout.fixed.horizontal,
											{
												layout = wibox.layout.flex.vertical,
												widget.gpu.vl,
												widget.gpu.pcie,
											},
										},
--]]
										widget.gpu.gl,
										widget.gpu.mem
									}
--								},
							},
							{
								widget = wibox.container.margin,
								left = dpi(2),
								widget.gpu.temp,
							}
						},
						{
							id = "ssd",
							layout = wibox.layout.fixed.horizontal,
							{
								widget = wibox.container.constraint,
								width = widget.def.barLen,
								{
									layout = wibox.layout.flex.vertical,
									spacing = 1,
									wibox.widget {
										layout = wibox.layout.stack,
										widget.ssd.usage.root,
										wibox.widget.textbox(color('#222222', " /")),
									},
									wibox.widget {
										layout = wibox.layout.stack,
										widget.ssd.usage.home,
										wibox.widget.textbox(color('#222222', " /home")),
									},
								}
							},
							{
								widget = wibox.container.margin,
								left = dpi(2),
								widget.ssd.temp,
							}
						},
						{
							id = "network",
							layout = wibox.layout.fixed.vertical,
							widget.network.up,
							widget.network.down,
						}
					}
				}
			},
			nil,
			{
				-- right
				widget = wibox.container.background, bg = beautiful.bg_normal,
				{
					widget = wibox.container.margin,
					left = dpi(2), right = dpi(2), top = dpi(2), bottom = dpi(2),
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(8),
						spacing_widget = wibox.widget.separator,
						{
							widget = wibox.container.constraint,
							strategy = "max",
							width = dpi(200),
							{
									id = "mpd",
									layout = wibox.layout.fixed.horizontal,
									{
										widget = wibox.container.margin,
										left = dpi(2), right = dpi(2),
										widget.mpd.icon
									},
									{
										widget = wibox.container.margin,
										left = dpi(2), top = dpi(3), bottom = dpi(3),
										{
											layout = wibox.layout.fixed.vertical,
											widget.mpd.nfo,
											widget.mpd.bar
										}
									}
							}
						},
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
	end
end)

mods.autostart.launch()
