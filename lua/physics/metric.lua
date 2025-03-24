---@generic T:Labeled
---@param map table<string,T>
---@param consts Labeled[]
function AddLabeledToMap(map,consts)
    
    for i = 1, #consts do
        local t = consts[i]
        map[t.label] = t
    end
    return map
end

MetricValue = {}
---@class MetricPrefix
---@field prefix string
---@field factor number
MetricPrefix = {}

Units = require 'lua.physics.units'
lrequire("value")

function MetricPrefix:__tostring()
    return tostring(self.factor)
end
---@return ValueWithUnit
function MetricPrefix.__index(self, key)
    u = Units[key]
    if not u then 
        error("Unknown unit '"..key.."'")
    end
    return u:withPrefix(self)
end

---@param power number
---@param symbol string
---@param base number? (10 by default)
---@return (MetricPrefix)
function MetricPrefix:new(power, symbol, base)
    base = base or 10
    -- print("Function "..stringify(Units.JUST:withPrefix))
    local newObj = {
        factor = base^power,
        base = base,
        power = power,
        prefix = symbol
    }
    
    return setmetatable(newObj, self)
end


Deca  = MetricPrefix:new(1, "да")
Hecto = MetricPrefix:new(2, "г")
Kilo  = MetricPrefix:new(3, "к")
Mega  = MetricPrefix:new(6, "М")
Giga  = MetricPrefix:new(9, "Г")
Tera  = MetricPrefix:new(12, "Т")
Peta  = MetricPrefix:new(15, "П")
Exa   = MetricPrefix:new(18, "Э")
Zetta = MetricPrefix:new(21, "З")
Yotta = MetricPrefix:new(24, "И")
JUST_P  = MetricPrefix:new(0, "")
Deci  = MetricPrefix:new(-1 , "д")
Canti = MetricPrefix:new(-2 , "с")
Milli = MetricPrefix:new(-3 , "м")
Micro = MetricPrefix:new(-6 , "мк")
Nano  = MetricPrefix:new(-9 , "н")
Pico  = MetricPrefix:new(-12, "п")
Femto = MetricPrefix:new(-15, "ф")
Atto  = MetricPrefix:new(-18, "а")
Zepto = MetricPrefix:new(-21, "з")
Yocto = MetricPrefix:new(-24, "и")

for k, v in pairs(Units) do
    _G[k] = v
end

print("-----")
print(Hecto)
print(Metr(10))
print(Canti.Metr(103))
print(Kilo.Metr) 
print(Kilo.Metr(1).value)
