local setmetatable = setmetatable
local rawget = rawget
local require = require

local function wrequire(table, key)
    local module = rawget(table, key)
    return module or require(table._NAME .. "." .. key)
end

local widgets = { _NAME = "modules" }
return setmetatable(widgets, { __index = wrequire })
