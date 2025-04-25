
function substitute(formula::Formula, args::Pair{Symbol, <:Any}...)
    c = copy(formula.expr)

    dict = Dict(args...)
    dictUnitLess = Dict([arg[1] => UnitSystem.extractValue(arg[2]) for arg in args]...)
    context = SubstitutionContext(false, false, dictUnitLess, dict)
    for option in supportedInlineOptions
        option == :display && continue
        context.isUnitLess = option != :inlineWithUnits
        expr = substitute(getproperty(c, option), context)
        setproperty!(c, option, expr)
    end
    return c
end
mutable struct SubstitutionContext
    isUnitLess::Bool
    isCalcLater::Bool
    unitless::Dict{Symbol, <:Any}
    withUnits::Dict{Symbol, <:Any}
end

current_dict(ctx::SubstitutionContext) = ctx.isUnitLess ? ctx.unitless : ctx.withUnits

Base.get(ctx::SubstitutionContext, expr, def) =
    haskey(ctx, expr) ? ctx[expr] : def

Base.haskey(ctx::SubstitutionContext, expr) = haskey(ctx.unitless, expr)
Base.getindex(ctx::SubstitutionContext, expr) = begin
    v = getindex(ctx.withUnits, expr)
    !isa(v, Number) && return v
    if ctx.isCalcLater || !ctx.isUnitLess
        v = UnitSystem.SI.toPreferred(v)
        return v
    end
    expr = UnitSystem.SI.convertExpr(v)
    v=UnitSystem.extractValue(v)
    expr===nothing && return v
    return expr(v)
end


substitute(::Nothing, dict::SubstitutionContext) = nothing
substitute(i::String, dict::SubstitutionContext) = error(i)
substitute(expr::Number, dict::SubstitutionContext) = expr
if @isdefined Unitful
    substitute(expr::Unitful.Units, dict::SubstitutionContext) = expr
end
substitute(expr::Symbol, dict::SubstitutionContext) = get(dict, expr, expr)
substitute(expr::Expr, dict::SubstitutionContext) = haskey(dict, expr) ? dict[expr] : substitute(Val(expr.head), expr, dict)
function substitute(::Val, expr::Expr, dict::SubstitutionContext)
    newArgs = []
    for arg in expr.args
        push!(newArgs, substitute(arg, dict))
    end
    return Expr(expr.head, newArgs...)
end

function substitute(::Val{:call}, expr::Expr, dict::SubstitutionContext)
    newArgs = similar(expr.args)
    newArgs[1] = expr.args[1]
    for i in 2:length(expr.args)
        newArgs[i] = substitute(expr.args[i], dict)
    end
    return Expr(expr.head, newArgs...)
end


function substitute((it,)::ValRef{:calcLater}, ctx::SubstitutionContext)
    prevU = ctx.isUnitLess
    try
        ctx.isUnitLess = false
        ctx.isCalcLater = true
        sub = substitute(it, ctx)
        value = Core.eval(Main, sub)
        # @show sub, value
        ctx.isUnitLess = prevU
        ctx.isCalcLater = false
        # prevU && return UnitSystem.extractValue(value)
        return value
    catch e
        ctx.isUnitLess = prevU
        ctx.isCalcLater = false
        error("Error while 'calcLatex' '$it' \n", ctx, "\n", e)
    end
end


