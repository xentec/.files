
local string = { match = string.match }
local setmetatable = setmetatable
local tonumber = tonumber
local type = type

local util = require("awful.util")

local pulse = { mt = {}, muted = {} }

local function ctl(arg)
	return util.pread("pulseaudio-ctl "..arg);
end

function pulse.new(update_func, step)
	if type(update_func) ~= "function" then return nil end
	pulse.step = step or 1
	pulse.update = update_func
	pulse.poll()
	return pulse
end

function pulse.poll()
	local volume, mute_speaker, mute_mic = string.match(ctl("full-status"), "(%d+) (%S+) (%S+)")

	pulse.value = tonumber(volume)
	pulse.muted.speaker = mute_speaker == "yes"
	pulse.muted.mic = mute_mic == "yes"
	pulse.update(pulse.muted, pulse.value)
end

function pulse.increase()
	pulse.value = ctl("up "..pulse.step or 1)
	pulse.poll()
end

function pulse.decrease()
	pulse.value = ctl("down "..pulse.step or 1)
	pulse.poll()
end

function pulse.mute(what)
	local mute = "mute"
	if what ~= nil then
		mute = mute.."-"..what
	end

	ctl(mute)
	pulse.poll()
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
