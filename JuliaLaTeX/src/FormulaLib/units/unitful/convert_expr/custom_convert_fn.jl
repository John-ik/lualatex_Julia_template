module __Custom_Convert_Holder

using Unitful
const Units = Unitful.Units
const FreeUnits = Unitful.FreeUnits
const basefactor = Unitful.basefactor
const tensfactor = Unitful.Unitful.tensfactor
const fp_overflow_underflow = Unitful.Unitful.fp_overflow_underflow
function ____custom_convert(s::Type{<:Units}, t::Type{<:Units})
    # Check if conversion is possible in principle
    dimension(s()) != dimension(t()) && throw(DimensionError(s(), t()))

    # use absoluteunit because division is invalid for AffineUnits;
    # convert to FreeUnits first because absolute ContextUnits might still
    # promote to AffineUnits
    conv_units = absoluteunit(FreeUnits(t())) / absoluteunit(FreeUnits(s()))
    inex, ex = basefactor(conv_units)
    e10 = 0
    if isa(ex, Rational)
        den, num = denominator(ex), numerator(ex)
        while num % 10 == 0
            num ÷= 10
            e10 += 1
        end
        while den % 10 == 0
            den ÷= 10
            e10 -= 1
        end
        while den & 1 == 0
            den >>>= 1
            num *= 5
            e10 -= 1
        end
        while den % 5 == 0
            den ÷= 5
            num *= 2
            e10 -= 1
        end
        while num & 1 == 0
            num >>>= 1
            den *= 5
            e10 += 1
        end
        while num % 5 == 0
            num ÷= 5
            den *= 2
            e10 += 1
        end
        ex = num // den
    else
        while ex % 10 == 0
            ex ÷= 10
            e10 += 1
        end
    end
    e10 += tensfactor(conv_units)
    inex_orig = inex

    if ex isa Rational && denominator(ex) == 1
        ex = numerator(ex)
    end

    inex = inex ≈ 1.0 ? 1 : inex
    result = inex * ex * 10.0^e10
    if fp_overflow_underflow(inex_orig, result)
        throw(ArgumentError(
            "Floating point overflow/underflow, probably due to large " *
            "exponents and/or SI prefixes in units",
        ))
    end
    return (inex, ex, e10)
end
function custom_convert(s::Units, t::Units)
    return __custom_convert(s, t)
end
function custom_convert(s::Type{<:Units}, t::Type{<:Units})
    return __custom_convert(s(), t())
end
@generated function __custom_convert(s::Units, t::Units)    #= @generated  =#
    return ____custom_convert(s, t)
end

end