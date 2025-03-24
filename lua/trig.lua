local trig_save = {
    acos = math.acos, asin = math.asin, atan = math.atan,
    cos = math.cos,   sin = math.sin,   tan = math.tan,
    cosh = math.cosh, sinh = math.sinh, tanh = math.tanh,
}

local static = {}

function DegreeMode ()
    if static.degree then return end
    static.degree = true
    static.radian = nil

    for key, val in pairs(trig_save) do
        math[key] = function (x)
            return val(toRad(x))
        end
    end
end

function RadianMode ()
    if static.radian then return end
    static.radian = true
    static.degree = nil

    for key, val in pairs(trig_save) do
        math[key] = val
    end
end