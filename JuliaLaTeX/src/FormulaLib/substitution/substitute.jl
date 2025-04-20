
function substitute(formula::Formula, args::Pair{Symbol, <:Any}...)
    c = copy(formula.expr)

    dict = Dict(args...)
    dictUnitLess = Dict([arg[1] => UnitSystem.extractValueUnitFrom(arg[2])[1] for arg in args]...)
    for option in supportedInlineOptions
        expr = substitute(getproperty(c, option), option == :inlineWithUnits ? dict : dictUnitLess)
        setproperty!(c, option, expr)
    end
    return c
end


substitute(::Nothing, dict::Dict) = nothing
substitute(expr::Number, dict::Dict) = expr
if @isdefined Unitful
    substitute(expr::Unitful.Units, dict::Dict) = expr
end
substitute(expr::Symbol, dict::Dict) = get(dict, expr, expr)
substitute(expr::Expr, dict::Dict) = haskey(dict, expr) ? dict[expr] : substitute(Val(expr.head), expr, dict)
function substitute(::Val, expr::Expr, dict::Dict)
    newArgs = []
    for arg in expr.args
        push!(newArgs, substitute(arg, dict))
    end
    return Expr(expr.head, newArgs...)
end

function substitute(::Val{:call}, expr::Expr, dict::Dict)
    newArgs = similar(expr.args)
    newArgs[1] = expr.args[1]
    for i in 2:length(expr.args)
        newArgs[i] = substitute(expr.args[i], dict)
    end
    return Expr(expr.head, newArgs...)
end


substitute((it,)::ValRef{:calcLater}, dict::Dict) = substitute(it, dict) |> eval


