struct ExponentNumber{T <: Integer} <: Real
    int_value::T
    dot_position::Int
    e10::Int
end
function dot_position(x::ExponentNumber)
    return x.dot_position
end
function exponent_10(x::ExponentNumber)
    return x.e10
end

function Base.promote_rule(::Type{ExponentNumber{A}}, ::Type{T}) where {A <: Integer, T <: Base.BitInteger}
    return ExponentNumber{promote_type(A, T)}
end
function Base.promote_rule(::Type{ExponentNumber{A}}, ::Type{ExponentNumber{B}}) where {A <: Integer, B <: Integer}
    return ExponentNumber{promote_type(A, B)}
end
ExponentNumber(n::T) where {T <: Base.BitInteger} = ExponentNumber{T}(n)
function ExponentNumber{T}(n::N) where {T <: Integer, N <: Base.BitInteger}
    ten = N(10)
    e10 = 0
    while (n % ten) == 0 && n > 0
        n ÷= ten
        e10 += 1
    end
    return ExponentNumber{T}(T(n), 0, e10)
end
ExponentNumber{T}(n::ExponentNumber{T}) where T <: Integer = n
ExponentNumber{T}(n::ExponentNumber{F}) where {T <: Integer, F <: Integer} = ExponentNumber(T(n.int_value), n.dot_position, n.e10)
ExponentNumber(n::ExponentNumber) = n


@save_exported export ExponentNumber

function real_exponent(e::ExponentNumber)
    return e.e10 - e.dot_position
end

function shift_dot(e::ExponentNumber{T}, offset::Int) where T <: Integer
    return ExponentNumber{T}(e.int_value, e.dot_position - offset, e.e10 - offset)
end
set_dot(new_position::Int) = Base.Fix2(set_dot, new_position)
function set_dot(e::ExponentNumber{T}, new_position::Int) where T <: Integer
    return shift_dot(e, -e.dot_position + new_position)
end
