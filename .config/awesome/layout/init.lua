local setmetatable = setmetatable
local rawget = rawget
local require = require

local function load(table, key)
    local module = rawget(table, key)
    return module or require("layout." .. key)
end

local mod = {}
return setmetatable(mod, { __index = load })
