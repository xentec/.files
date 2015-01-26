--------------------------
-- Licensed under the MIT
--  * (c) 2013, Andrej U.
--------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}

-- gpu.nv: queries information about a nVidia GPU
local gpu = {}

local function worker(format, warg)

    --local device
    local query
    if warg and warg.query then
        if type(warg.query) == "string" then
            query = { warg.query }
        else
            query = warg.query
        end
    else
        query = { "[gpu:0]/UsedDedicatedGPUMemory", "[gpu:0]/TotalDedicatedGPUMemory", "[gpu:0]/GPUCurrentClockFreq", "[gpu:0]/GPUCoreTemp", "[fan:0]/GPUCurrentFanSpeed" }
    end

    local queries = "-q "..table.concat(query, " -q ")

    local f = io.popen("nvidia-settings -t "..queries)
    local state = {}
    for k,_ in f:lines() do
        table.insert(state,k)
    end
    f:close()
    return state
end
-- }}}

return setmetatable(gpu, { __call = function(_, ...) return worker(...) end })
