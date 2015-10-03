local setmetatable = setmetatable
local type = type
local os = os

local util = require("awful.util")

local pulse = { mt = {}, mute = {} }

local function ctl(arg)
	return util.pread("pulseaudio-ctl "..arg);
end

function pulse.new(update_func, step)
	if type(update_func) ~= "function" then return nil end
	pulse.step = step or 1
	pulse.update = update_func
	return pulse
end

function pulse.poll()
	local volume, mute_speaker, mute_mic = string.gmatch(ctl("full-status"), "%d+ %S+ %S+")

	pulse.value = tonumber(volume)
	pulse.mute.speaker = mute_speaker == "yes"
	pulse.mute.mic = mute_mic == "yes"
	pulse.update(pulse.mute, pulse.value)
end

function pulse.increase()
	pulse.value = ctl("up "..pulse.step or 1)
	poll()
end

function pulse.decrease()
	pulse.value = ctl("down "..pulse.step or 1)
	poll()
end

function pulse.mute(what)
	local mute = "mute"
	if what ~= nil then
		mute = mute.."-"..what
	end

	ctl(mute)
	poll()
end

function pulse.toggleMic()
	pulse.mute("input")
end

function pulse.toggleSpeaker()
	pulse.mute()
end


function pulse.mt:__call(...)
	return pulse.new(...)
end

return setmetatable(pulse, pulse.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
