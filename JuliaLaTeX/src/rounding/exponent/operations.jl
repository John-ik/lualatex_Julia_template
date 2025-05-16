
function (Base.:*)(n, ::typeof(exp))
    return ExponentNumber(n)
end
function (Base.:*)(e1::ExponentNumber, e2::ExponentNumber)
    em = e1.int_value * e2.int_value
    e10 = 0
    while em % 10 == 0 && em > 0
        em ÷= 10
        e10 += 1
    end
    return ExponentNumber(em, e1.dot_position + e2.dot_position, e10 + e1.e10 + e2.e10)
end
function (Base.:/)(e1::ExponentNumber, e2::ExponentNumber)
    e3 = ExponentNumber(e1.int_value / e2.int_value)
    return ExponentNumber(
        e3.int_value,
        e3.dot_position + e1.dot_position - e2.dot_position,
        e3.e10 + e1.e10 - e2.e10,
    )
end


for op in [:+, :-, :rem]
    local opImport = Expr(:., :Base, QuoteNode(op))
    eval(quote
        function $opImport(e1::ExponentNumber{A}, e2::ExponentNumber{B}) where {A <: Integer, B <: Integer}
            e10 = min(e1.e10, e2.e10)
            local r1 = real_exponent(e1)
            local r2 = real_exponent(e2)
            if r1 < r2
                e10 = r1
                em = $op(e1.int_value, e2.int_value * B(10)^(r2 - e10))
            elseif r1 > r2
                e10 = r2
                em = $op(e1.int_value * A(10)^(r1 - e10), e2.int_value)
            else
                e10 = r1
                em = $op(e1.int_value, e2.int_value)
            end
            while em % 10 == 0 && em > 0
                em ÷= 10
                e10 += 1
            end
            local out_dot = max(e1.dot_position, e2.dot_position)
            return ExponentNumber(em, out_dot, e10 + out_dot)
        end
    end)
end
for op in [:<,:<=,:(==),:(!=),:(>),:(>=)]
    local opImport = Expr(:., :Base, QuoteNode(op))
    eval(quote
        function $opImport(e1::ExponentNumber{A}, e2::ExponentNumber{B}) where {A <: Integer, B <: Integer}
            e10 = min(e1.e10, e2.e10)
            local r1 = real_exponent(e1)
            local r2 = real_exponent(e2)
            if r1 < r2
                e10 = r1
                return $op(e1.int_value, e2.int_value * B(10)^(r2 - e10))
            elseif r1 > r2
                e10 = r2
                return $op(e1.int_value * A(10)^(r1 - e10), e2.int_value)
            else
                e10 = r1
                return $op(e1.int_value, e2.int_value)
            end
        end
    end)
end


Base.abs(e::ExponentNumber{T}) where T = ExponentNumber{T}(abs(e.int_value), e.dot_position, e.e10)
function Base.round(e::ExponentNumber{T}, m::RoundingMode) where T
    e.dot_position == 0 && e.e10 >= 0 && (return e)
    real_exp = real_exponent(e)
    if real_exp >= 0
        if e.dot_position > 0
            ExponentNumber{T}(e.int_value, 0, real_exp)
        end
        return e
    end
    return ExponentNumber{T}(round(float(e.int_value) / float(T(10)^-real_exp), m), 0, 0)
end

Base.isinf(e::ExponentNumber{T}) where T = isinf(e.int_value)
Base.isfinite(e::ExponentNumber{T}) where T = isfinite(e.int_value)
function (Base.:*)(e::ExponentNumber{T}, n::P) where {T <: Integer, P <: Integer}
    C = promote_type(P, T)
    return ExponentNumber{C}(C(e.int_value)^n, trunc(Int, n * e.dot_position), trunc(Int, n * e.e10))
end


#= function Base.rem(e1::ExponentNumber{A}, e2::ExponentNumber{B}) where {A <: Integer, B <: Integer}

end =#