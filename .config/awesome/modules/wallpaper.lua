-- Autostart
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")

local cairo = require("lgi").cairo
local color = require("gears.color")

local wallpaper = {}
wallpaper.dirs = {}
wallpaper.images = {}
wallpaper.interval = 60*60


local function rotate()
	  -- set wallpaper to current index for all screens
	for s in screen do
		local sel = math.random(1, #wallpaper.images)
		--gears.wallpaper.fit(wallpaper.images[sel], s, "#AA0000")
		
		naughty.notify({ screen = s, timeout = 5, text = '<span color="DeepSkyBlue"> '.. string.gsub(wallpaper.images[sel], "(.*/)(.*)", "%2") .. '</span>' });

		gears.wallpaper.maximized(wallpaper.images[sel], s)
	end
end

local function start()
	math.randomseed(os.time())
	wallpaper.timer = gears.timer.start_new(wallpaper.interval, rotate)
	naughty.notify({ timeout = 5, text = '<span color="DeepSkyBlue">Rotating '.. #wallpaper.images .. ' wallpapers</span>' });
	gears.timer.delayed_call(rotate)
end

local function scandir(dir)
	awful.spawn.with_line_callback('sh -c "file --mime-type '..dir..'/*"', 
	{
		stdout = function(line)
			local m = line:gmatch("([^:]+):%s*([^/]+)/")
			local file = m()
	--      if m() == "image" then
				table.insert(wallpaper.images, file)
	--      end
--			naughty.notify({ timeout = 5, text = ''..#wallpaper.images });
		end,
		output_done = function(exit, reason)

			for i, savedDir in ipairs(wallpaper.dirs) do
				if dir == savedDir then
					table.remove(wallpaper.dirs, i)
					if #wallpaper.dirs ~= 0 then
						return
					else
						break
					end
				end
			end
			start()		
		end
	})
end


function wallpaper.launch()
	for _,dir in ipairs(wallpaper.dirs) do
		scandir(dir)
	end
end

function wallpaper.add(dir)
	table.insert(wallpaper.dirs, dir)
	--naughty.notify({ timeout = 5, title= "WP", text = '<span color="DeepSkyBlue">'.. table.concat(wallpaper.images,'\n') .. '</span>' });
end

function wallpaper.next()
	-- stop the timer (we don't need multiple instances running at the same time)
	wallpaper.timer:stop()
	--restart the timer
	wallpaper.timer = gears.timer.start_new(wallpaper.interval, rotate)
	
	gears.timer.delayed_call(rotate)
end

return wallpaper
