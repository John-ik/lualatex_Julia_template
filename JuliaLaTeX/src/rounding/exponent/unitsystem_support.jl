UnitSystem.extract_unit(::ExponentNumber) = nothing
UnitSystem.extract_value(x::ExponentNumber) = x

UnitSystem.SI.preferredUnit(x::ExponentNumber) = nothing
UnitSystem.SI.toPreferred(x::ExponentNumber) = x
# UnitSystem.SI.convertExpr(x::Unitful.Quantity{ExponentNumber}) = UnitSystem.SI.convertExpr()(x)|>eval

