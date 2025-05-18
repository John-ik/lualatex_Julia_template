include("exp_number.jl")
include("from_float.jl")
include("from_rational.jl")
include("operations.jl")
include("convertions.jl")
include("show_exp_number.jl")
include("unitsystem_support.jl")

function exponent_number_to_float(x::ExponentNumber{BigInt})
    a = BigFloat(2)^real_exponent(x)
    b = x.int_value * BigFloat(5)^real_exponent(x)
    return a * b
end
function exponent_number_to_float(x::ExponentNumber)
    a = 2.0^real_exponent(x)
    b = x.int_value * 5.0^real_exponent(x)
    return a * b
end


function clear_garbage(x::ExponentNumber{T}, max_deep::Int = 15) where T <: Integer
    (x.dot_position < max_deep) && (return x)


    v = x.int_value
    in_dot_len = x.dot_position

    extra_l = in_dot_len - max_deep

    out_part = v ÷ (T(10)^(extra_l - 1))

    if out_part % 10 >= 5
        out_part = (out_part ÷ 10) + 1
    else
        out_part ÷= 10
    end
    extra_e10 = 0
    while (out_part & 1) == 0 && (out_part % 5) == 0
        out_part ÷= 10
        extra_e10 += 1
    end


    new_dot_pos = max_deep - extra_e10
    if new_dot_pos < 0
        return ExponentNumber{T}(out_part, 0, -new_dot_pos + x.e10)
    else
        return ExponentNumber{T}(out_part, new_dot_pos, x.e10)
    end
end