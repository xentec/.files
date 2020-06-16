-- Autostart
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")

--local cairo = require("lgi").cairo
--local color = require("gears.color")

local wallpaper = {
	dirs = {},
	images = {},
	interval = 60*60
}

local function rotate()
	  -- set wallpaper to current index for all screens
	for s in screen do
		local sel = math.random(1, #wallpaper.images)
		naughty.notify({ screen = s, timeout = 5, text = '<span color="DeepSkyBlue"> '.. string.gsub(wallpaper.images[sel], "(.*/)(.*)", "%2") .. '</span>' });
		gears.wallpaper.maximized(wallpaper.images[sel], s)
	end
end

function wallpaper.launch()
	wallpaper.images = {}
	for _,dir in ipairs(wallpaper.dirs) do
		awful.spawn.with_line_callback('sh -c "file -i '..dir..'/*"',
		{
			stdout = function(line)
				local file, mime = line:gmatch("([^:]+):%s*([^/]+)/.+")()
				if mime == "image" then
					table.insert(wallpaper.images, file)
				end
			end,
			output_done = function()
				math.randomseed(os.time())
				naughty.notify({ timeout = 5, text = '<span color="DeepSkyBlue">Rotating '.. #wallpaper.images .. ' wallpapers</span>' });

				wallpaper.timer = gears.timer {
					timeout   = wallpaper.interval,
					call_now  = true,
					autostart = true,
					callback  = rotate
				}
			end
		})
	end
end

function wallpaper.add(dir)
	table.insert(wallpaper.dirs, dir)
	--naughty.notify({ timeout = 5, title= "WP", text = '<span color="DeepSkyBlue">'.. table.concat(wallpaper.images,'\n') .. '</span>' });
end

function wallpaper.next()
	wallpaper.timer:again()
	gears.timer.delayed_call(rotate)
end

return wallpaper
