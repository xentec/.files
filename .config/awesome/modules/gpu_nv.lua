--------------------------
-- Licensed under the MIT
--  * (c) 2013-2015, Andrej U.
--------------------------

local newtimer     = require("lain.helpers").newtimer

local awful        = require("awful")
local wibox        = require("wibox")

local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { gmatch = string.gmatch, match = string.match, lower = string.lower }
local table = { concat = table.concat, insert = table.insert }
local tonumber = tonumber

--local naughty = require("naughty")

-- gpu.nv: queries information about a nVidia GPU
local gpu = {}
local default_query = 
{
    "GPUUtilization",
    "UsedDedicatedGPUMemory", 
    "TotalDedicatedGPUMemory", 
    "GPUCoreTemp", 
    "GPUCurrentFanSpeed",
    "GPUCurrentClockFreqs"
}
--[[
local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 2
    local settings = args.settings or function() end

--    local gpus = args.gpus or {}
    local extra_queries = args.extra_queries or {}

    gpu.widget = args.widget or wibox.widget.textbox('')
    gpu.query = "-q "..table.concat(awful.util.table.join(default_query, extra_queries), " -q ")

    function update()

        gpu_now = {}
        gpu_now.usage = {}
        gpu_now.mem = {}
        gpu_now.freq = {}
        gpu_now.extra = {}

        local f = io.popen("nvidia-settings -t "..gpu.query)

        -- parse default queries
        local i = 1
        for line in f:lines()
        do
            if     default_query[i] == "GPUUtilization"
            then
                for k, v in string.gmatch(line, "(%w+)=(%w+)") do
                    gpu_now.usage[k:lower()] = tonumber(v)
                end    
            elseif default_query[i] == "UsedDedicatedGPUMemory"  then gpu_now.mem.used  = tonumber(line)
            elseif default_query[i] == "TotalDedicatedGPUMemory" then gpu_now.mem.total = tonumber(line)
            elseif default_query[i] == "GPUCoreTemp"             then gpu_now.temp      = tonumber(line)
            elseif default_query[i] == "GPUCurrentFanSpeed"      then gpu_now.fan_speed = tonumber(line)
            elseif default_query[i] == "GPUCurrentClockFreqs"
            then 
                local freq_core, freq_memory = string.match(line, "(%d+),(%d+)")
                gpu_now.freq.core = tonumber(freq_core)
                gpu_now.freq.mem = tonumber(freq_memory)
            end
            if i >= #default_query then break end -- were done here

            i = i+1
        end

        -- parse extra queries
        i = 1
        for line in f:lines()
        do
            gpu_now.extra[i] = line
            i = i+1
        end
        f:close()

        widget = gpu.widget
        settings()
    end

    newtimer("gpu", timeout, update)

    return gpu.widget
end


    local zone = { -- Known temperature data sources
        ["sys"]  = {"/sys/class/thermal/",     file = "temp",       div = 1000},
        ["hwmon"]= {"/sys/class/hwmon/",       file = "temp1_input",div = 1000},
        ["core"] = {"/sys/devices/platform/",  file = "temp2_input",div = 1000},
        ["proc"] = {"/proc/acpi/thermal_zone/",file = "temperature"}
    } --  Default to /sys/class/thermal
    warg = type(warg) == "table" and warg or { warg, "sys" }

    -- Get temperature from thermal zone
    local _thermal = helpers.pathtotable(zone[warg[2] ][1] .. warg[1])

    local data = warg[3] and _thermal[warg[3] ] or _thermal[zone[warg[2] ].file]
    if data then
        if zone[warg[2] ].div then
            return {data / zone[warg[2] ].div}
        else -- /proc/acpi "temperature: N C"
            return {tonumber(string.match(data, "[%d]+"))}
        end
    end


]]--

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 2
    local settings = args.settings or function() end

--    local gpus = args.gpus or {}
    local extra_queries = args.extra_queries or {}

    gpu.widget = args.widget or wibox.widget.textbox('')
    gpu.query = "-q "..table.concat(awful.util.table.join(default_query, extra_queries), " -q ")

    function update()

        gpu_now = {}
        gpu_now.usage = {}
        gpu_now.mem = {}
        gpu_now.freq = {}
        gpu_now.extra = {}

        local f = io.popen("nvidia-settings -t "..gpu.query)

        -- parse default queries
        local i = 1
        for line in f:lines()
        do
            if     default_query[i] == "GPUUtilization"
            then
                for k, v in string.gmatch(line, "(%w+)=(%w+)") do
                    gpu_now.usage[k:lower()] = tonumber(v)
                end    
            elseif default_query[i] == "UsedDedicatedGPUMemory"  then gpu_now.mem.used  = tonumber(line)
            elseif default_query[i] == "TotalDedicatedGPUMemory" then gpu_now.mem.total = tonumber(line)
            elseif default_query[i] == "GPUCoreTemp"             then gpu_now.temp      = tonumber(line)
            elseif default_query[i] == "GPUCurrentFanSpeed"      then gpu_now.fan_speed = tonumber(line)
            elseif default_query[i] == "GPUCurrentClockFreqs"
            then 
                local freq_core, freq_memory = string.match(line, "(%d+),(%d+)")
                gpu_now.freq.core = tonumber(freq_core)
                gpu_now.freq.mem = tonumber(freq_memory)
            end
            if i >= #default_query then break end -- were done here

            i = i+1
        end

        -- parse extra queries
        i = 1
        for line in f:lines()
        do
            gpu_now.extra[i] = line
            i = i+1
        end
        f:close()

        widget = gpu.widget
        settings()
    end

    newtimer("gpu", timeout, update)

    return gpu.widget
end

return setmetatable(gpu, { __call = function(_, ...) return worker(...) end })
