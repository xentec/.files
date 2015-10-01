local setmetatable = setmetatable
local os = os

local util = require("awful.util")

local pulse = { mt = {}, mute = {} }

local function call(arg)
	return util.pread("pulseaudio-ctl "..arg);
end

function pulse.new(update_func, step)
	if type(update_func) ~= "function" then return nil end
	pulse.step = step or 1
	pulse.update = update_func

	local status = pulse.update()


	return pulse
end

function pulse.poll()
    local status = {}
    for val in string.gmatch(call("full-status"), "%S+") do
  		table.insert(status, val)
	end

	pulse.value = tonumber(status[1])
	pulse.mute.speaker = status[2] == "yes"
	pulse.mute.mic = status[3] == "yes";
	pulse.update(pulse.mute, pulse.value)
end

function pulse.increase()
	pulse.value = call("up "..pulse.step or 1)
	poll()
end

function pulse.decrease()
	pulse.value = call("down "..pulse.step or 1)
	poll()
end

function pulse.mute(what)
	call(what == "speaker" and "mute" or "mute-input")
	poll()
end

function pulse.toggleMic()
	pulse.mute("mic")
end

function pulse.toggleSpeaker()
	pulse.mute("speaker")
end


function pulse.mt:__call(...)
	return pulse.new(...)
end

return setmetatable(pulse, pulse.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
