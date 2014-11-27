-- Autostart
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local io = { popen = io.popen }

local wallpaper = {}
wallpaper.images = {}
--wallpaper.timer = {}

wallpaper.interval = 60*60

local function isImage(file)

end

local function scandir(dir)
    local i, t, popen = 0, {}, io.popen
    for filename in popen('sh -c "file --mime-type '..dir..'/*"'):lines() do
    	local m = filename:gmatch("([^:]+):%s*([^/]+)/")
    	local file = m()
--        if m() == "image" then
            i = i + 1
            t[i] = file
--        end
--        naughty.notify({ timeout = 5, text = file });
    end
    return t
end


function wallpaper.init()
	wallpaper.timer = timer { timeout = 1 }
	wallpaper.timer:connect_signal("timeout", function()
	 

	  -- set wallpaper to current index for all screens
	  for s = 1, screen.count() do
	  	local sel = math.random( 1, #wallpaper.images)
	    gears.wallpaper.fit(wallpaper.images[sel], s, false)
	  end
	 
	  -- stop the timer (we don't need multiple instances running at the same time)
	  wallpaper.timer:stop()
	 	 
	  --restart the timer
	  wallpaper.timer.timeout = wallpaper.interval
	  wallpaper.timer:start()
	end)
	naughty.notify({ timeout = 5, text = '<span color="DeepSkyBlue">Rotating '.. #wallpaper.images .. ' wallpapers</span>' });
	wallpaper.timer:start()
end

function wallpaper.add(dir)
	wallpaper.images = scandir(dir)
	--naughty.notify({ timeout = 5, title= "WP", text = '<span color="DeepSkyBlue">'.. table.concat(wallpaper.images,'\n') .. '</span>' });

end

return wallpaper
