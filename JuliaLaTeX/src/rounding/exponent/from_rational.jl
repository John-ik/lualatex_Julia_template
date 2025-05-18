
function Base.promote_rule(::Type{ExponentNumber{A}}, ::Type{Rational{B}}) where {A <: Integer, B <: Integer}
    return ExponentNumber#= {promote_type(A, B)} =#
end

function ExponentNumber{A}(rational::Rational{A}) where A <: Integer
    #TODO just division
    return ExponentNumber{A}(ExponentNumber(float(rational)))
end
function ExponentNumber(rational::Rational{A}) where A <: Integer
    #TODO just division
    return (ExponentNumber(float(rational)))
end