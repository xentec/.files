local awful = require("awful")
local gears = require("gears")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local naughty = require("naughty")
local lain = require("lain")

local pulse = require("modules.pulse")
local wallpaper = require("modules.wallpaper")

local exec = awful.spawn.with_shell
local spawn = awful.spawn

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- {{{ Key bindings
local globalkeys = gears.table.join(
	awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
			  {description = "show help", group = "awesome"}),
	awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
			  {description = "view previous", group = "tag"}),
	awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
			  {description = "view next", group = "tag"}),
	awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
			  {description = "go back", group = "tag"}),

	awful.key({ modkey,           }, "j",
		function ()
			awful.client.focus.byidx( 1)
		end,
		{description = "focus next by index", group = "client"}
	),
	awful.key({ modkey,           }, "k",
		function ()
			awful.client.focus.byidx(-1)
		end,
		{description = "focus previous by index", group = "client"}
	),

	-- Layout manipulation
	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
			  {description = "swap with next client by index", group = "client"}),
	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
			  {description = "swap with previous client by index", group = "client"}),
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
			  {description = "focus the next screen", group = "screen"}),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
			  {description = "focus the previous screen", group = "screen"}),
	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
			  {description = "jump to urgent client", group = "client"}),
	awful.key({ modkey,           }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{description = "go back", group = "client"}),

	-- Standard program
	awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
			  {description = "open a terminal", group = "launcher"}),
	awful.key({ modkey, "Control" }, "r", awesome.restart,
			  {description = "reload awesome", group = "awesome"}),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit,
			  {description = "quit awesome", group = "awesome"}),

	awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
			  {description = "increase master width factor", group = "layout"}),
	awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
			  {description = "decrease master width factor", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
			  {description = "increase the number of master clients", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
			  {description = "decrease the number of master clients", group = "layout"}),
	awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
			  {description = "increase the number of columns", group = "layout"}),
	awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
			  {description = "decrease the number of columns", group = "layout"}),
	awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
			  {description = "select next", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
			  {description = "select previous", group = "layout"}),

	awful.key({ modkey, "Control" }, "n",
			  function ()
				  local c = awful.client.restore()
				  -- Focus restored client
				  if c then
					  client.focus = c
					  c:raise()
				  end
			  end,
			  {description = "restore minimized", group = "client"}),

	-- Prompt
	awful.key({ modkey },            "r",     function () my.monitor.main.prompt:run() end,
			  {description = "run prompt", group = "launcher"}),

	awful.key({ modkey }, "x",
				function ()
					awful.prompt.run {
						prompt       = "Run Lua code: ",
						textbox      = awful.screen.focused().mypromptbox.widget,
						exe_callback = awful.util.eval,
						history_path = awful.util.get_cache_dir() .. "/history_eval"
					}
				end,
			  {description = "lua execute prompt", group = "awesome"}),
	-- Menubar
	awful.key({ modkey }, "p", function() menubar.show() end,
			  {description = "show the menubar", group = "launcher"}),
	awful.key({ modkey }, "d", function() exec("dinu") end,
			  {description = "show the dinu launcher", group = "launcher"}),

	-- Volume
	awful.key({ }, "XF86AudioMute",     	pulse.toggleSpeaker,
			  {description = "mute speakers", group = "volume"}),
	awful.key({ }, "XF86AudioRaiseVolume",  pulse.increase,
			  {description = "increase volume", group = "volume"}),
	awful.key({ }, "XF86AudioLowerVolume",  pulse.decrease,
			  {description = "decrease volume", group = "volume"}),
	awful.key({ }, "XF86AudioMicMute",  	pulse.toggleMic,
			  {description = "mute speakers", group = "volume"}),

	-- Media
	awful.key({ }, "XF86AudioPlay", function () spawn("mpc -h ".. my.mpd.host .." toggle"); my.widget.mpd.worker.update() end,
			  {description = "start playing", group = "mpd"}),
	awful.key({ }, "XF86AudioStop", function () spawn("mpc -h ".. my.mpd.host .." stop"); my.widget.mpd.worker.update() end,
			  {description = "stop playing", group = "mpd"}),
	awful.key({ }, "XF86AudioPrev", function () spawn("mpc -h ".. my.mpd.host .." prev"); my.widget.mpd.worker.update() end,
			  {description = "switch to previous title", group = "mpd"}),
	awful.key({ }, "XF86AudioNext", function () spawn("mpc -h ".. my.mpd.host .." next"); my.widget.mpd.worker.update() end,
			  {description = "switch to next song", group = "mpd"}),
	awful.key({ "Shift" }, "XF86AudioPrev", function () spawn("mpc -h ".. my.mpd.host .." seek -5"); my.widget.mpd.worker.update() end,
			  {description = "jump 5 seconds back", group = "mpd"}),
	awful.key({ "Shift" }, "XF86AudioNext", function () spawn("mpc -h ".. my.mpd.host .." seek +5"); my.widget.mpd.worker.update() end,
			  {description = "jump 5 seconds forward", group = "mpd"}),
	awful.key({ "Shift" }, "XF86AudioLowerVolume", function () spawn("mpc -h ".. my.mpd.host .." seek -1"); my.widget.mpd.worker.update() end,
			  {description = "scroll through song backward", group = "mpd"}),
	awful.key({ "Shift" }, "XF86AudioRaiseVolume", function () spawn("mpc -h ".. my.mpd.host .." seek +1"); my.widget.mpd.worker.update() end,
			  {description = "scroll through song forward", group = "mpd"}),

	-- Backlight
	awful.key({ }, "XF86MonBrightnessUp",   function () spawn("xbacklight -inc 10") end,
			  {description = "increase brightness by 10%", group = "monitor"}),
	awful.key({ }, "XF86MonBrightnessDown", function () spawn("xbacklight -dec 10") end,
			  {description = "decrease brightness by 10%", group = "monitor"}),
	awful.key({ "Shift" }, "XF86MonBrightnessUp",   function () spawn("xbacklight -set 100") end,
			  {description = "set brightness to maximum", group = "monitor"}),
	awful.key({ "Shift" }, "XF86MonBrightnessDown", function () spawn("xbacklight -set 10") end,
			  {description = "set brightness to minimum", group = "monitor"}),

	-- Screen capture
	awful.key({ modkey,           }, "Print", function () exec("scr")        end),
	awful.key({ modkey, "Shift"   }, "Print", function () exec("seen video")  end),

	awful.key({ modkey, "Control" }, "Right", wallpaper.next),

	-- launch short cut
	awful.key({ modkey }, "q",      function() spawn(my.browser) end),
	awful.key({ modkey }, "Return", function () spawn(my.terminal) end),

	awful.key({ modkey }, "c", function()
		local l = {}
		for _, c in ipairs(client.get()) do
			table.insert(l, lain.util.markup.bold(c.name..":").." c:"..tostring(c.class))
		end
		naughty.notify{ timeout = 0, text = table.concat(l, "\n")}
	end),

	-- mpv
	awful.key({ modkey }, "v",
		function ()
			---local v = selection()
			--if not v then return end
			naughty.notify{ timeout = 5, title = "Playing..."}
			exec('mpv (xsel -bo)')
		end,
		{description = "play clipboard content in mpv", group = "media"}),

	awful.key({ modkey, "Shift" }, "v",
		function ()
			---local v = selection()
			--if not v then return end
			naughty.notify{ timeout = 5, title = "Looping..."}
			exec('mpv --loop (xsel -bo)')
		end,
		{description = "loop clipboard content in mpv", group = "media"}),

	awful.key({ modkey }, "XF86AudioRaiseVolume",
		function ()
			naughty.notify{ timeout = 5, title = "Volume ignition..."}
			exec('mpv ~/hl1-sfx.opus')
		end,
		{description = "play a short sound to wakeup speakers", group = "media"}),


	awful.key({ modkey }, "y", function () spawn("dm-tool lock") end)
)

local clientkeys = gears.table.join(
	awful.key({ modkey,           }, "f",
		function (c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end),
	awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
			  {description = "close", group = "client"}),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
			  {description = "toggle floating", group = "client"}),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
			  {description = "move to master", group = "client"}),
	awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ,
			  {description = "move to screen", group = "client"}),
	awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
			  {description = "toggle keep on top", group = "client"}),
	awful.key({ modkey, "Shift"   }, "t",      function (c) c.sticky = not c.sticky          end,
			  {description = "toggle keep on top", group = "client"}),
	awful.key({ modkey,           }, "n",
		function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end ,
		{description = "minimize", group = "client"}),
	awful.key({ modkey,           }, "m",
		function (c)
			c.maximized = not c.maximized
			c:raise()
		end ,
		{description = "maximize", group = "client"})
)


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9,
				function()
					local screen = awful.screen.focused()
					local tag = screen.tags[i]
					if tag then
						tag:view_only()
					end
				end,
				{description = "view tag #"..i, group = "tag"}),
		-- Toggle tag.
		awful.key({ modkey, "Control" }, "#" .. i + 9,
				function()
					local screen = awful.screen.focused()
					local tag = screen.tags[i]
					if tag then
						awful.tag.viewtoggle(tag)
					end
				end,
				{description = "toggle tag #" .. i, group = "tag"}),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
				function()
					if client.focus then
						local tag = client.focus.screen.tags[i]
						if tag then
							client.focus:move_to_tag(tag)
						end
					end
				end,
				{description = "move focused client to tag #"..i, group = "tag"}),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
				function()
					if client.focus then
						local tag = client.focus.screen.tags[i]
						if tag then
							client.focus:toggle_tag(tag)
						end
					end
				end,
				{description = "toggle focused client on tag #" .. i, group = "tag"})
	)
end

return {
	mod = modkey,
	global = globalkeys,
	client = clientkeys
}
