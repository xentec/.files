--------------------------
-- Licensed under the MIT
--  * (c) 2013-2015, Andrej U.
--------------------------

local newtimer     = require("lain.helpers").newtimer

local wibox        = require("wibox")

local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { gmatch = string.gmatch, lower = string.lower }
local table = { concat = table.concat, insert = table.insert }
local tonumber = tonumber


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

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 2
    local settings = args.settings or function() end

--    local gpus = args.gpus or { "0" }
--    local extra = args.extra_queries or {}
        
    gpu.widget = args.widget or wibox.widget.textbox('')

    function update()
        local queries = "-q "..table.concat(default_query, " -q ")
        
        gpu_now = {}
        gpu_now.usage = {}
        gpu_now.mem = {}
        gpu_now.freq = {}

        local i = 1
        local f = io.popen("nvidia-settings -t "..queries)
        for line in f:lines() do
            if default_query[i] == "GPUUtilization" 
            then
                for k, v in string.gmatch(line, "(%w+)=(%w+)") do
                    gpu_now.usage[k:lower()] = tonumber(v)
                end    
            elseif default_query[i] == "UsedDedicatedGPUMemory"  then gpu_now.mem.used  = tonumber(line)
            elseif default_query[i] == "TotalDedicatedGPUMemory" then gpu_now.mem.total = tonumber(line)
            elseif default_query[i] == "GPUCoreTemp"             then gpu_now.temp         = tonumber(line)
            elseif default_query[i] == "GPUCurrentFanSpeed"      then gpu_now.fan_speed    = tonumber(line)
            elseif default_query[i] == "GPUCurrentClockFreqs"    
            then 
                local freq_core, freq_memory = string.gmatch(line, "(%d+),(%d+)")
                gpu_now.freq.core = tonumber(freq_core)
                gpu_now.freq.mem = tonumber(freq_memory)
            end
            i = i+1
        end
        f:close()

        widget = gpu.widget
        settings()
    end

    newtimer("gpu", timeout, update)

    return gpu.widget
end
-- }}}

return setmetatable(gpu, { __call = function(_, ...) return worker(...) end })
