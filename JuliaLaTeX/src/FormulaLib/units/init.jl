

module UnitSystem
Core.eval(Main, quote
    STD_NUMBERS = Union{
        Int8, Int16, Int32, Int64, Int128, BigInt,
        UInt8, UInt16, UInt32, UInt64, UInt128,
        Float16, Float32, Float64, BigFloat,
        Irrational,
        Rational,
        Complex,
    }
end)
include("abstract_split.jl")


# applyUnitTo(value::Number, unit::Complex{Bool}) = value * unit
applyUnitTo(value, ::Nothing) = value
# extractValueUnitFrom(value::Complex) = (value.im, im)

extractValueUnitFrom(it) = (extract_value(it),extract_unit(it))
extract_unit(::Union{Nothing,Main.STD_NUMBERS}) = nothing
extract_value(value::Union{Nothing,Main.STD_NUMBERS}) = value

include("si.jl")




include("UnitFulSupport.jl")
end
US=UnitSystem

