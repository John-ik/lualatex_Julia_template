-- Load symmath

-- disable FFI (speed up calculation) if shell_escape no
if status.shell_escape ~= 1 then
    package.loaded.ffi = nil
end

-- import symbol math
package.path = package.path .. ";./libs/?/?.lua;./libs/?.lua"

require 'symmath'.setup{
    fixVariableNames=true -- example: theta -> \theta
}

lrequire 'const'
lrequire 'rounding'

vars = symmath.vars
var =  symmath.var
sin = symmath.sin
cos = symmath.cos
tan = symmath.tan


symmath.pi:nameForExporter('LaTeX', 'pi') -- replace default unicode char for pi by LaTeX symbol
symmath.tostring = function (...)
    local save_tostring = tostring
    function tostring(value)
        if type(value) == 'number' then
            if value ~= value then
                return "\\text{NaN}"
            end
            if value == math.huge then
                return '\\infty'
            elseif value == -math.huge then
                return '-\\infty'
            end
            value = rounding.toNdigitsScience(value, 5, 0.5)
            if value > 10^5 and value < 10^13 then
                local exp = math.floor(math.log(value, 10))
                return '{ '..save_tostring(value * 10^(-exp))..' \\cdot 10^{'..exp..'} }'
            end
            if math.floor(value) == value then
                return save_tostring(math.floor(value))
            end
            local s = save_tostring(value)
            local mantissa, _, exp = string.match(s, '(%d+(%.?%d*))e?([-+]?%d*)')
            if not mantissa then error("WTF?"..s) end
            if exp ~= '' then
                texio.write('term and log', 'TOSTRING', 
                    '{ '..save_tostring(mantissa) .. ' \\cdot 10^{'..save_tostring(tonumber(exp))..'} }'
                    , '\n')
                return '{ '..save_tostring(mantissa) .. ' \\cdot 10^{'..save_tostring(tonumber(exp))..'} }'
                -- return 'NUMER'
            end
            return mantissa
        end
        return save_tostring(value)
    end
    local str = symmath.export.LaTeX(...) -- export function
    tostring = save_tostring
    return str
end
symmath.tan.nameForExporterTable.LaTeX = '\\tg'

