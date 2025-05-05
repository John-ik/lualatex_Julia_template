
abstract type RoundingType end

struct FunctionRoundingType{T <: Base.Callable} <: RoundingType
    f::T
end

(f::FunctionRoundingType)(it)=f.f(it)

make_rounding(f::Base.Callable) = FunctionRoundingType(f)