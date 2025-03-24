---@class Const
---@field unit UnitWithPrefix
---@field value Value
Const = symmath.Constant:subclass()
Const.precedence = 10
Const.name = 'Const'

ConstShouldBeNamed = false
---@return string
function Const:tostringNamed()
    local prev = ConstShouldBeNamed;
    ConstShouldBeNamed = true;
    local v = tostring(self)
    ConstShouldBeNamed = prev;
    return v;
end

lrequire 'value'

---@param value Value|number
---@param symbol string
---@param text   string
---@param hide   boolean|nil
function Const:init(value, symbol, text, hide)
    if not Value:isa(value) then
        if type(value) == 'number' then
            value = Value(value, JUST)
        else
            error("Not a Value: " .. stringify(value))
        end
    end

    self.value = value
    self.symbol = symbol
    self.text = text
    self.hide = hide
end

function Const:clone()
	return Constant(self.value.value --[[, self.symbol]])
end

function Const:evaluateDerivative(deriv, ...)
    return Constant(0)
end

function Const:evaluateLimit(x, a, side)
	return self
end

local function prepareName(name)
    if name:find '%^' or name:find '_' then
        return '{' .. name .. '}'
    end
    return name
end

table = require 'ext.table'
LaTeX = require 'symmath.export.LaTeX'

LaTeX.lookupTable = table(LaTeX.lookupTable):union {
    ---@param self Export
    ---@param expr Const
    [Const] = function(self, expr)
        texio.write('term and log', unicode.utf8.format('DEBUG Const: %s %s \n', type(expr.value), tostring(expr.value)))
        if (ConstShouldBeNamed) then
            return table {
                prepareName(expr.symbol),
                table(
                    { force = true }
                )
            }
        end
        return self:apply(expr.value)
    end
}
