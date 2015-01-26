---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local os = { time = os.time }
local io = { lines = io.lines }
local setmetatable = setmetatable
local string = { match = string.match, format = string.format }
local helpers = require("vicious.helpers")
-- }}}


-- Net: provides state and usage statistics of all network interfaces
-- vicious.widgets.net
local net = {}


-- Initialize function tables
local nets = {}
-- Variable definitions

local units = { " ", "K", "M", "G", "T", "P", "E" }

local function uformat(array, key, value)

    array["{"..key.."_b}"] = string.format("%.1f", value)

    local i = 1
    while value > 1000.0 do
        value = value / 1024.0
        i = i + 1
    end

    array["{"..key.."_suf}"] = units[i]
    array["{"..key.."_sb}"] = value

    return array
end

-- {{{ Net widget type
local function worker(format)
    local args = {}

    -- Get NET stats
    for line in io.lines("/proc/net/dev") do
        -- Match wmaster0 as well as rt0 (multiple leading spaces)
        local name = string.match(line, "^[%s]?[%s]?[%s]?[%s]?([%w]+):")
        if name ~= nil and name ~= "lo" then
            -- Received bytes, first value after the name
            local recv = tonumber(string.match(line, ":[%s]*([%d]+)"))
            -- Transmited bytes, 7 fields from end of the line
            local send = tonumber(string.match(line,
             "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))

            uformat(args, name .. " rx", recv)
            uformat(args, name .. " tx", send)

            -- Operational state and carrier detection
            local sysnet = helpers.pathtotable("/sys/class/net/" .. name)
            args["{"..name.." carrier}"] = tonumber(sysnet.carrier) or 0

            local now = os.time()
            if nets[name] == nil then
                -- Default values on the first run
                nets[name] = {}
                uformat(args, name .. " down", 0)
                uformat(args, name .. " up",   0)
            else -- Net stats are absolute, substract our last reading
                local interval = now - nets[name].time
                if interval <= 0 then interval = 1 end

                local down = (recv - nets[name][1]) / interval
                local up   = (send - nets[name][2]) / interval

                uformat(args, name .. " down", down)
                uformat(args, name .. " up",   up)
            end

            nets[name].time = now

            -- Store totals
            nets[name][1] = recv
            nets[name][2] = send
        end
    end

    return args
end
-- }}}

return setmetatable(net, { __call = function(_, ...) return worker(...) end })
