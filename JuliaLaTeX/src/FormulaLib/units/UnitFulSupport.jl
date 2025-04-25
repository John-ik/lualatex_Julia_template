

if !@isdefined Unitful
    using Unitful: Unitful
end

if Core.eval(@__MODULE__, Expr(:isdefined, :Unitful))
    applyUnitTo(value::Number, it::Unitful.Units) = value * it
    applyUnitTo(value::Unitful.Quantity, it::Unitful.Units) = Unitful.uconvert(it, value)
    # applyUnitTo(value::Number, it::Unitful.Quantity) = applyUnitTo(value, extractValueUnitFrom(it)[2])

    extractUnit(it::Unitful.Quantity) =  Unitful.unit(it)
    extractValue(it::Unitful.Quantity) = it.val

    extractUnit(it::Unitful.Units) = it
    extractValue(::Unitful.Units) = nothing

    SI.toPreferred(value::Unitful.Quantity) = Unitful.uconvert(SI.preferredUnit(value), value)

    SI.preferredUnit(it::Number) = Unitful.NoUnits
    SI.preferredUnit(it::Unitful.Quantity) = SI.preferredUnit(extractUnit(it))
    SI.preferredUnit(it::Unitful.Units) = SI.preferredUnit(Unitful.dimension(it))
    SI.preferredUnit(it::Unitful.Dimensions) = Unitful.upreferred(it)
    SI.preferredUnit(it::Unitful.Dimension) = Unitful.upreferred(it)

    SI.convertExpr(value::Unitful.Quantity) = SI.convertExpr(extractUnit(value))
    # SI.convertExpr(value::Unitful.Units) = SI
    function SI.convertExpr(fromobj::Unitful.Units, targetobj::Unitful.Units)
        from = typeof(fromobj)
        target = typeof(targetobj)

        t0 = from <: Unitful.AffineUnits ? from.parameters[end][end] : 0
        t1 = target <: Unitful.AffineUnits ? target.parameters[end][end] : 0



        factor = Unitful.convfact(targetobj, fromobj)
        if factor == 1
            t0 == 0 && t1 == 0 && return identity
            t0 == 0 && return x -> Expr(:call, :+, x, t1)
            t1 == 0 && return x -> Expr(:call, :-, x, t1)
            return x -> Expr(:call, :+, x, -t0, t1)
        end
        if typeof(factor) <: Rational
            if factor.num == 1
                d = log10(factor.den)
                if abs(floor(d) - d) <= 0.00001
                    factor = Expr(:call, :^, 10, -Int(d))
                end
            end
        else

        end
        t0 == 0 && t1 == 0 && return x -> Expr(:call, :*, x, factor)
        t0 == 0 && return x -> Expr(:call, :+, Expr(:call, :*, x, factor), t1)
        t1 == 0 && return x -> Expr(:call, :*, Expr(:call, :-, x, t0), factor)
        return x -> Expr(:call, :+, Expr(:call, :*, Expr(:call, :-, x, t0), factor), t1)
    end
    SI.convertExpr(::typeof(Unitful.DefaultSymbols.°),::typeof(Unitful.upreferred(Unitful.DefaultSymbols.°))) = x -> :($x * (π / 180))
    SI.convertExpr(::typeof(Unitful.upreferred(Unitful.DefaultSymbols.°)),::typeof(Unitful.DefaultSymbols.°)) = x -> :($x * (180 / π))

end

function splitExpressionWithUnit(T::Val{:macrocall}, expr::Expr)::Tuple
    expr.args[1] != Symbol("@u_str") && return defaultSplitExprWithUnit(T, expr)
    # stack=stacktrace()
    # lastStack=(1:4).|> x->stack[x]
    # @show lastStack
    return (nothing, expr)
end
function splitExpressionWithUnit(T::Val{:call}, expr::Expr)::Tuple
    expr.args[1] != :* && return defaultSplitExprWithUnit(T, expr)
    newArgs = map(splitExpressionWithUnit,expr.args)

    filtered = filter(!isnothing, map(first,newArgs))
    unit = nothing
    for arg in newArgs
        arg[2] !== nothing && (unit = arg[2])
    end
    length(filtered) == 2 && return (filtered[2], unit)
    length(filtered) == 1 && return (nothing, unit)
    return tuple(Expr(expr.head, filtered...), unit)
end
