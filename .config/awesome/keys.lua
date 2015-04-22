local awful = require("awful")
local menubar = require("menubar")
local vicious = require("vicious")

local pulse = require("modules.pulse")
local wallpaper = require("modules.wallpaper")

local exec = awful.util.spawn_with_shell
local spawn = awful.util.spawn

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- {{{ Key bindings
local globalkeys = awful.util.table.join(
		awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
		awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
		awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

		awful.key({ modkey,           }, "j",
				function ()
						awful.client.focus.byidx( 1)
						if client.focus then client.focus:raise() end
				end),
		awful.key({ modkey,           }, "k",
				function ()
						awful.client.focus.byidx(-1)
						if client.focus then client.focus:raise() end
				end),
		awful.key({ modkey,           }, "w", function () end),

		-- Layout manipulation
		awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
		awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
		awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
		awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
		awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
		awful.key({ modkey,           }, "Tab",
				function ()
						awful.client.focus.history.previous()
						if client.focus then
								client.focus:raise()
						end
				end),

		-- Standard program
		awful.key({ modkey, "Control" }, "r", awful.util.restart),
		awful.key({ modkey, "Shift"   }, "q", awesome.quit),

		awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
		awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
		awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
		awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
		awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
		awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
		awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
		awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

		awful.key({ modkey, "Control" }, "n", awful.client.restore),

		-- Prompt
		awful.key({ modkey }, "r", function () bar.main.prompt[mouse.screen]:run() end),
		awful.key({ modkey }, "x",
							function ()
									awful.prompt.run({ prompt = "Run Lua code: " },
									bar.main.prompt[mouse.screen].widget,
									awful.util.eval, nil,
									awful.util.getdir("cache") .. "/history_eval")
							end),
		-- Menubar
		awful.key({ modkey }, "p", function() menubar.show() end),

		-- Volume
		awful.key({ }, "XF86AudioMute",     	pulse.togglemute),
		awful.key({ }, "XF86AudioRaiseVolume",  pulse.increase),
		awful.key({ }, "XF86AudioLowerVolume",  pulse.decrease),

		-- Media
		awful.key({ }, "XF86AudioPlay", function () exec("mpc -h ".. my.mpd_host .." toggle"); my.widget.mpd.worker.update() end),
		awful.key({ }, "XF86AudioStop", function () exec("mpc -h ".. my.mpd_host .." stop"); my.widget.mpd.worker.update() end),
		awful.key({ }, "XF86AudioPrev", function () exec("mpc -h ".. my.mpd_host .." prev"); my.widget.mpd.worker.update() end),
		awful.key({ }, "XF86AudioNext", function () exec("mpc -h ".. my.mpd_host .." next"); my.widget.mpd.worker.update() end),

		-- Backlight
		awful.key({ }, "XF86MonBrightnessUp",   function () spawn("xbacklight -inc 10") end),
		awful.key({ }, "XF86MonBrightnessDown", function () spawn("xbacklight -dec 10") end),
		awful.key({ "Shift" }, "XF86MonBrightnessUp",   function () spawn("xbacklight -set 100") end),
		awful.key({ "Shift" }, "XF86MonBrightnessDown", function () spawn("xbacklight -set 10") end),


		-- Screen capture
		awful.key({ modkey,           }, "Print", function () spawn("seen")        end),
		awful.key({ modkey, "Shift"   }, "Print", function () spawn("seen video")  end),

		awful.key({ modkey, "Control" }, "Right", wallpaper.next),

		-- launch short cut
		awful.key({ modkey,	          }, "q",      function() spawn(my.browser) end),
		awful.key({ modkey,           }, "Return", function () spawn(my.terminal) end)
)

local clientkeys = awful.util.table.join(
		awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
		awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),

		awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
		awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
		awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
		awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
		awful.key({ modkey,           }, "n",
				function (c)
						-- The client currently has the input focus, so it cannot be
						-- minimized, since minimized clients can't have the focus.
						c.minimized = true
				end),
		awful.key({ modkey,           }, "m",
				function (c)
						c.maximized_horizontal = not c.maximized_horizontal
						c.maximized_vertical   = not c.maximized_vertical
				end)
)

-- Compute the maximum number of digit we need, limited to 9
--[[ local keynumber = 0
for s = 1, screen.count() do
	 keynumber = math.min(9, math.max(#tags[s], keynumber))
end
]]

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
		globalkeys = awful.util.table.join(globalkeys,
				awful.key({ modkey }, "#" .. i + 9,
									function ()
												local screen = mouse.screen
												if tags[screen][i] then
														awful.tag.viewonly(tags[screen][i])
												end
									end),
				awful.key({ modkey, "Control" }, "#" .. i + 9,
									function ()
											local screen = mouse.screen
											if tags[screen][i] then
													awful.tag.viewtoggle(tags[screen][i])
											end
									end),
				awful.key({ modkey, "Shift" }, "#" .. i + 9,
									function ()
											if client.focus and tags[client.focus.screen][i] then
													awful.client.movetotag(tags[client.focus.screen][i])
											end
									end),
				awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
									function ()
											if client.focus and tags[client.focus.screen][i] then
													awful.client.toggletag(tags[client.focus.screen][i])
											end
									end))
end

return {
	mod = modkey,
	global = globalkeys,
	client = clientkeys
}
