
local string = { match = string.match }
local setmetatable = setmetatable
local tonumber = tonumber
local type = type

local spawn = require("awful.spawn")

local pulse = { mt = {}, muted = {} }

local function ctl(arg, callback)
	spawn.easy_async("pulseaudio-ctl "..arg,
		function (stdout, stderr, _, exist)
			callback(stdout)
		end)
end

function pulse.new(update_func, step)
	if type(update_func) ~= "function" then return nil end
	pulse.step = step or 1
	pulse.update = update_func
	pulse.poll()
	return pulse
end

function pulse.poll()
	ctl("full-status", function(ret)
		local volume, mute_speaker, mute_mic = string.match(ret, "(%d+) (%S+) (%S+)")

		pulse.value = tonumber(volume) or 0
		pulse.muted.speaker = mute_speaker == "yes"
		pulse.muted.mic = mute_mic == "yes"
		pulse.update(pulse.muted, pulse.value)
	end)
end

function pulse.increase()
	ctl("up "..pulse.step or 1, function (ret)
		pulse.value = ret
		pulse.poll()
	end)
end

function pulse.decrease()
	ctl("down "..pulse.step or 1, function (ret)
		pulse.value = ret
		pulse.poll()
	end)
end

function pulse.mute(what)
	local mute = "mute"
	if what ~= nil then
		mute = mute.."-"..what
	end

	ctl(mute, function( ... )
		pulse.poll()
	end)
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
