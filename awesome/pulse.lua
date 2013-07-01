local setmetatable = setmetatable
local os = os

local util = require("awful.util")

local pulse = { mt = {} }

local function update()
	pulse.value = util.pread("ponymix get-volume")
	pulse.muted = util.pread("sh -c 'ponymix is-muted; echo -n $?;'") == "0"
	pulse.update(pulse.muted, pulse.value)
end

local function ponymix(arg)
	local ret = util.pread("ponymix "..arg)
	update()
	return ret
end

function pulse.new(update_func, step)
	if type(update_func) ~= "function" then return nil end
	pulse.step = step or 1
	pulse.update = update_func
	update()
	return pulse
end

function pulse.increase()
	ponymix("increase "..pulse.step or 1)
end

function pulse.decrease()
	ponymix("decrease "..pulse.step or 1)
end

function pulse.mute(bool)
	if bool then
		ponymix("mute")
	else
		ponymix("unmute")
	end
end

function pulse.togglemute()
	pulse.mute(pulse.muted == false)
end

function pulse.mt:__call(...)
	return pulse.new(...)
end

return setmetatable(pulse, pulse.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
