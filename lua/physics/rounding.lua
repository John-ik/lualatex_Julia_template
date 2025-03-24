rounding = {}

--- Round 
---@param value number  
---@param n number number of digits after point
---@param diff number ('0.5' -> round(0.5) = 1; '0.7' -> round(0.3) = 1)
---@return number
function rounding.toNdigits(value, n, diff)
    return math.floor(value * 10^n + diff) / 10^n
end

--- Science notaion rounding
---@param value number  
---@param n number number of digits after point in science notation
---@param diff number ('0.5' -> round(0.5) = 1; '0.7' -> round(0.3) = 1)
---@return number
function rounding.toNdigitsScience(value, n, diff)
    if value == 0 then return 0 end
    local exp = math.floor(math.log(value, 10))
    local mantissa = rounding.toNdigits(value * 10^(-exp), n, diff)
    return mantissa * 10^exp
end

--- Round 
---@param value number 
---@return number
function rounding.to3digitScience(value)
    return rounding.toNdigitsScience(value, 3, 0.5)
end

--- Round Theta
---@param value number 
---@return number
function rounding.theta(value)
    return rounding.toNdigitsScience(value, 0, 0.7)
end


function rounding.asTheta(value, theta)
    theta = rounding.theta(theta)
    local exp = math.floor(math.log(theta, 10))
    return rounding.toNdigits(value, -exp, 0.5), theta
end