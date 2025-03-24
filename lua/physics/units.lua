
local table = require 'ext.table'
local complex = require 'complex'
local Variable = require 'symmath.Variable'
---@class UnitWithPrefix
---@field prefix MetricPrefix
---@field unit Unit
UnitWithPrefix = Variable:subclass()
UnitWithPrefix.precedence = 10	-- high since it can't have child nodes
UnitWithPrefix.name = 'UnitWithPrefix'

---@class Unit
---@field name string
local Unit = {}
function Unit.isNumber (x) return false end

---@param prefix MetricPrefix
---@return UnitWithPrefix
function Unit:withPrefix(prefix)
    dprint("withPrefix:", stringify(self), stringify(prefix))
    prefix = assert(prefix, 'Unit expected prefix symbol')
    return UnitWithPrefix(self, prefix)
end




---@param symbol string
---@param prefix MetricPrefix
function Unit:new(symbol)
    return setmetatable({name = assert(symbol, "Unit expected symbol")},self)
end
function Unit.__call(self, value)
    return Value(value, self)
end
function Unit.__index(self, key)
    return Unit[key]
end
function Unit:__tostring()
    return self.name
end
---@param unit Unit
---@param prefix MetricPrefix
function UnitWithPrefix:init(unit, metricPrefix)
    self.name = assert(unit, "Unit expected symbol")
    self.prefix = metricPrefix
    self.unit=unit
    dprint("Unit with metricPrefix:: '"..stringify(self).."'")
    self:nameForExporter('LaTeX', "\\:\\text{"..metricPrefix.prefix..unit.name.."}")
end

---@param value number
function UnitWithPrefix:__call(value)
    dprint("Try to create value with value '"..tostring(value).."'")
    return Value(value,self)
end

function UnitWithPrefix:__tostring()
    if stringify(self.prefix) == "nil" then
        error("Fuck yo lether men\n"..stringify(self))
    end
    dprint("<<Unit prefix '"..stringify(self.prefix).."'>>")
    return tostring(self.prefix.prefix)..tostring(self.unit)
end

---@class Units
---@field JUST     Unit '',
---@field One      Unit 'шт.',
---@field Kg       Unit 'кг',
---@field Metr     Unit 'м',
---@field Second   Unit 'с',
---@field Amper    Unit 'А',
---@field Kelvin   Unit 'К',
---@field Mole     Unit 'моль',
---@field Candela  Unit 'кд',
---@field Volt     Unit 'В',
---@field Coulomb  Unit 'Кл',
---@field Hertz    Unit 'Гц',
---END


---
---@return Units
local function makeUnits()
    local file = io.open(
        debug.getinfo(1, "Sl").short_src,
        "r")
    ---@type string
    local text = file:read("a");
    file:close()

    local find = string.find
    local sub = string.sub

    local _, start_ = find(text, "@class Units")
    local end_, _ = find(text, "---END", start_)
    text = sub(text, start_ + 1, end_ - 1)
    local i = 0;
    local units_={}
    while i < #text do
        local has,nameStart= find(text, "@field ",i)
        if not has then
            break
        end
        local nameEnd = find(text, " ",nameStart+2)
        local name=sub(text,nameStart+1,nameEnd-1);
        local argStart=find(text,"'",nameEnd)
        local argEnd=find(text,"'",argStart+1)
        
        local arg_=sub(text,argStart+1,argEnd-1)

        units_[name]=Unit:new(arg_)
        print("Unit."..name.."='"..arg_.."'")
        i=argEnd+1;
    end
    return units_
end

return makeUnits()
