

include("custom_convert_fn.jl")
include("special_units.jl")

function SI.convertExpr(fromobj::Unitful.Units, targetobj::Unitful.Units)
    from = typeof(fromobj)
    fromobj == targetobj && return SI.ConvertExpr.IdentityConversionExpr{from}()
    target = typeof(targetobj)

    t0 = from <: Unitful.AffineUnits ? from.parameters[end][end] : 0
    t1 = target <: Unitful.AffineUnits ? target.parameters[end][end] : 0

    (irr, rat, e10) = __Custom_Convert_Holder.custom_convert(targetobj, fromobj)
    return SI.ConvertExpr.construct_convert_expr(from, target, t0, t1, irr, rat, e10)
end
