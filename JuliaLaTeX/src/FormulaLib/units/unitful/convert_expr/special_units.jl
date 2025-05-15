


@generated function SI.ConvertExpr.build_convert_function(::SI.ConvertExpr.SimpleConversionExpr{typeof(Unitful.u"°"), typeof(Unitful.NoUnits), t0, t1, irr, rat, e10}) where {t0, t1, irr, rat, e10}
    return if e10 == 0
        x -> :($x * (π / 180))
    elseif e10 == 1
        x -> :($x * (π / 180) * 10)
    else
        x -> :($x * (π / 180) * 10^$e10)
    end
end
@generated function SI.ConvertExpr.build_convert_function(::SI.ConvertExpr.SimpleConversionExpr{typeof(Unitful.NoUnits), typeof(Unitful.u"°"), t0, t1, irr, rat, e10}) where {t0, t1, irr, rat, e10}
    return if e10 == 0
        x -> :($x * (180 / π))
    elseif e10 == 1
        x -> :($x * (180 / π) * 10)
    else
        x -> :($x * (180 / π) * 10^$e10)
    end
end