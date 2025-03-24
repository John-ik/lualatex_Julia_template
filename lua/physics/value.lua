

---@class Value
---@field unit Unit
---@field value number
Value = Constant:subclass()
Value.precedence=10
Value.name="Value"

---@param value number
---@param unit Unit|UnitWithPrefix
function Value:init(value,unit)
    if(unit.withPrefix) then
        unit=unit:withPrefix(JUST_P)
    end
    self.unit = unit
    self.value = value * unit.prefix.factor;
    self.visible_value = value
    
    -- self:nameForExporter('LaTeX',tostring())
end

function Value.__le(a, b)
    if Value:isa(a) then
        dprint("value:<=", a.value, "<=", stringify(b, true))
        return a.value <= b
    elseif Value:isa(b) then
        dprint("value:<=",  stringify(a, true), "<=", b.value)
        return a <= b.value
    end
end

function Value.__lt(a, b)
    dprint("value:<", stringify(a, true), "<", stringify(b, true))
    return a <= b and not (b <= a)
end

function Value.__eq(a, b)
    dprint("value:==", stringify(a, true), "==", stringify(b, true))
    if Value:isa(a) and type(b) == 'number' then
        return a.value == b
    elseif type(b) == 'number' and Value:isa(b) then
        return a == b.value
    end
    return a.value == b.value
end

table = require 'ext.table'
LaTeX = require 'symmath.export.LaTeX'

LaTeX.lookupTable = table(LaTeX.lookupTable):union{
    ---@param self Export
    ---@param expr Value
    [Value] = function (self, expr)
        texio.write('term and log', unicode.utf8.format('DEBUG Value: %s %s \n', type(expr.visible_value), tostring(expr.visible_value)))
        return table{
            self:apply(expr.visible_value),
            table(
                self:apply(expr.unit),
                {force=true}
            )
        }
    end
}

