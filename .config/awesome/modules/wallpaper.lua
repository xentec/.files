-- Autostart
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local io = { popen = io.popen }

local cairo = require("lgi").cairo
local color = require("gears.color")

local wallpaper = {}
wallpaper.images = {}
--wallpaper.timer = {}

wallpaper.interval = 60*60

-- The size of the root window
local root_geom
do
    local geom = screen[1].geometry
    root_geom = {
        x = 0, y = 0,
        width = geom.x + geom.width,
        height = geom.y + geom.height
    }
    for s = 1, screen.count() do
        local g = screen[s].geometry
        root_geom.width = math.max(root_geom.width, g.x + g.width)
        root_geom.height = math.max(root_geom.height, g.y + g.height)
    end
end

--- Prepare the needed state for setting a wallpaper
-- @param s The screen to set the wallpaper on or nil for all screens
-- @return The available geometry (table with entries width and height), a
--         that should be used for setting the wallpaper and a cairo context
--         for drawing to this surface
local function prepare_wallpaper(s)
    local geom = s and screen[s].geometry or root_geom
    local img = gears.surface(root.wallpaper())

    if not img then
        -- No wallpaper yet, create an image surface for just the part we need
        img = cairo.ImageSurface(cairo.Format.RGB24, geom.width, geom.height)
        img:set_device_offset(-geom.x, -geom.y)
    end

    local cr = cairo.Context(img)

    -- Only draw to the selected area
    cr:translate(geom.x, geom.y)
    cr:rectangle(0, 0, geom.width, geom.height)
    cr:clip()

    return geom, img, cr
end

--- Set a fitting wallpaper.
-- @param surf The wallpaper to set. Either a cairo surface or a file name.
-- @param s The screen whose wallpaper should be set. Can be nil, in which case
--          all screens are set.
-- @param background The background color that should be used. Gets handled via
--                   gears.color. The default is black.
local function set(surf, s, background)
    local geom, img, cr = prepare_wallpaper(s)
    local surf = gears.surface(surf)
    local background = gears.color(background)

    -- Fill the area with the background
    cr.operator = cairo.Operator.SOURCE
    cr.source = background
    cr:paint()

    -- Now fit the surface
    local w, h = gears.surface.get_size(surf)
    local scale = geom.width / w
    if h * scale > geom.height then
       scale = geom.height / h
    end
    cr:translate((geom.width - (w * scale)) / 2, (geom.height - (h * scale)) / 2)
    cr:rectangle(0, 0, w * scale, h * scale)
    cr:clip()
    cr:scale(scale, scale)
    cr:set_source_surface(surf, 0, 0)
    cr:paint()

    gears.wallpaper.set(img)
end

local function scandir(dir)
	local i, t, popen = 0, {}, io.popen
	for filename in popen('sh -c "file --mime-type '..dir..'/*"'):lines() do
		local m = filename:gmatch("([^:]+):%s*([^/]+)/")
		local file = m()
--      if m() == "image" then
			i = i + 1
			t[i] = file
--      end
--      naughty.notify({ timeout = 5, text = file });
	end
	return t
end

local function rotate()
	  -- set wallpaper to current index for all screens
	for s = 1, screen.count() do
		local sel = math.random( 1, #wallpaper.images)
		set(wallpaper.images[sel], s, "#222222")
	end
	 
	-- stop the timer (we don't need multiple instances running at the same time)
	wallpaper.timer:stop()
		 
	--restart the timer
	wallpaper.timer.timeout = wallpaper.interval
	wallpaper.timer:start()
end

function wallpaper.init()
	wallpaper.timer = timer { timeout = 1 }
	wallpaper.timer:connect_signal("timeout", rotate)
	wallpaper.timer:start()
	naughty.notify({ timeout = 5, text = '<span color="DeepSkyBlue">Rotating '.. #wallpaper.images .. ' wallpapers</span>' });
end

function wallpaper.add(dir)
	wallpaper.images = scandir(dir)
	--naughty.notify({ timeout = 5, title= "WP", text = '<span color="DeepSkyBlue">'.. table.concat(wallpaper.images,'\n') .. '</span>' });

end

function wallpaper.next()
	rotate()
end

return wallpaper
