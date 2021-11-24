---------------------------------------------------------------------------
--- Block layouts module for awful.
--
-- @author Josh Komoroske
-- @copyright 2012 Josh Komoroske
-- @module awful.layout
---------------------------------------------------------------------------

-- Grab environment we need
local tag = require("awful.tag")
local client = require("awful.client")
local ipairs = ipairs
local math = math
local capi =
{
		mouse = mouse,
		screen = screen,
		mousegrabber = mousegrabber
}

local layout = {}

layout.resize_jump_to_corner = true

local function mouse_resize_handler(c, _, _, _, orientation)
	orientation = orientation or "south"
	local wa = c.screen.workarea
	local mwfact = c.screen.selected_tag.master_width_factor
	local cursor
	local g = c:geometry()
	local offset = 0
	local corner_coords
	local coordinates_delta = {x=0,y=0}

	cursor = "cross"
	if g.height+15 > wa.height then
		offset = g.height * .5
		cursor = "sb_h_double_arrow"
	elseif not (g.y+g.height+15 > wa.y+wa.height) then
			offset = g.height
	end
	corner_coords = { x = wa.x + wa.width * mwfact, y = g.y + offset }


	if layout.resize_jump_to_corner then
			capi.mouse.coords(corner_coords)
	else
			local mouse_coords = capi.mouse.coords()
			coordinates_delta = {
				x = corner_coords.x - mouse_coords.x,
				y = corner_coords.y - mouse_coords.y,
			}
	end

	local prev_coords = {}
	capi.mousegrabber.run(function (_mouse)
		if not c.valid then return false end

		_mouse.x = _mouse.x + coordinates_delta.x
		_mouse.y = _mouse.y + coordinates_delta.y
		for _, v in ipairs(_mouse.buttons) do
			if v then
				prev_coords = { x =_mouse.x, y = _mouse.y }
				local fact_x = (_mouse.x - wa.x) / wa.width
				local fact_y = (_mouse.y - wa.y) / wa.height
				local new_mwfact

				local geom = c:geometry()

				-- we have to make sure we're not on the last visible
				-- client where we have to use different settings.
				local wfact
				local wfact_x, wfact_y
				if (geom.y+geom.height+15) > (wa.y+wa.height) then
						wfact_y = (geom.y + geom.height - _mouse.y) / wa.height
				else
						wfact_y = (_mouse.y - geom.y) / wa.height
				end

				if (geom.x+geom.width+15) > (wa.x+wa.width) then
						wfact_x = (geom.x + geom.width - _mouse.x) / wa.width
				else
						wfact_x = (_mouse.x - geom.x) / wa.width
				end


				new_mwfact = fact_x
				wfact = wfact_y

				c.screen.selected_tag.master_width_factor
					= math.min(math.max(new_mwfact, 0.01), 0.99)
				client.setwfact(math.min(math.max(wfact,0.01), 0.99), c)
				return true
			end
		end
		return prev_coords.x == _mouse.x and prev_coords.y == _mouse.y
	end, cursor)
end

local function arrange(p, orientation)
	local wa = p.workarea
	local cls = p.clients

	-- Swap workarea dimensions, if our orientation is "east"
	if orientation == 'east' then
			wa.width, wa.height = wa.height, wa.width
			wa.x, wa.y = wa.y, wa.x
	end

	if #cls > 0 then
		local rows, cols = 1, #cls

		for k, c in ipairs(cls) do
			k = k - 1
			local g = {}

			local row, col
			row = k % rows
			col = math.floor(k / rows)

			local lrows, lcols
			if k >= rows * cols - rows then
				lrows = #cls - (rows * cols - rows)
				lcols = cols
			else
				lrows = rows
				lcols = cols
			end

			if row == lrows - 1 then
				g.height = wa.height - math.ceil(wa.height / lrows) * row
				g.y = wa.height - g.height
			else
				g.height = math.ceil(wa.height / lrows)
				g.y = g.height * row
			end

			if col == lcols - 1 then
				g.width = wa.width - math.ceil(wa.width / lcols) * col
				g.x = wa.width - g.width
			else
				g.width = math.ceil(wa.width / lcols)
				g.x = g.width * col
			end

			g.y = g.y + wa.y
			g.x = g.x + wa.x

			-- Swap window dimensions, if our orientation is "east"
			if orientation == 'east' then
				g.width, g.height = g.height, g.width
				g.x, g.y = g.y, g.x
			end

			p.geometries[c] = g
		end
	end
end

--- Horizontal layout.
-- @param screen The screen to arrange.
layout.horizontal = {}
layout.horizontal.name = "blk_h"
function layout.horizontal.arrange(p)
		return arrange(p, "east")
end

--- Vertical layout.
-- @param screen The screen to arrange.
layout.name = "blk_v"
function layout.arrange(p)
		return arrange(p, "south")
end

function layout.mouse_resize_handler(c, corner, x, y)
		return mouse_resize_handler(c, corner, x, y)
end



return layout

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
