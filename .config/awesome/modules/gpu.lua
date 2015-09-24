--------------------------
-- Licensed under the MIT
--  * (c) 2013-2015, Andrej U.
--------------------------

local newtimer     = require("lain.helpers").newtimer

local wibox        = require("wibox")

local io = { popen = io.popen }
local table = { concat = table.concat, insert = table.insert }
local setmetatable = setmetatable


-- gpu.nv: queries information about a nVidia GPU
local gpu = {}

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 2
    local settings = args.settings or function() end

    local query = args.query or 
        { 
          "[gpu:0]/UsedDedicatedGPUMemory", 
          "[gpu:0]/TotalDedicatedGPUMemory", 
          "[gpu:0]/GPUCurrentClockFreq", 
          "[gpu:0]/GPUCoreTemp", 
          "[fan:0]/GPUCurrentFanSpeed"
        }

    gpu.widget = args.widget or wibox.widget.textbox('')

    function update()
        local queries = "-q "..table.concat(query, " -q ")
        
        gpu_now = {}

        local f = io.popen("nvidia-settings -t "..queries)
        for k,_ in f:lines() do
            table.insert(gpu_now, k)
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
