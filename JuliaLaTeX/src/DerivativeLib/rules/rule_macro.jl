module DefineRuleMacro
export @rule

AdjointMapType = Dict{Union{Expr, Symbol}, Symbol}

collectAdjoints(::AdjointMapType, it::Symbol) = it
collectAdjoints(::AdjointMapType, it::Number) = it
collectAdjoints(collector::AdjointMapType, ::Val{Symbol("'")}, it::Expr) = begin
    a = it.args[1]
    if !haskey(collector, a)
        sym = Symbol("d$(length(collector))")
        collector[a] = sym
        return sym
    end
    collector[a]
end
collectAdjoints(collector::AdjointMapType, @nospecialize(::Val), it::Expr) = Expr(it.head, [collectAdjoints(collector, arg) for arg in it.args]...)
collectAdjoints(collector::AdjointMapType, it::Expr) = collectAdjoints(collector, Val(it.head), it)

extractArgName(it::Symbol)::Symbol = it
extractArgName(it::Expr)::Symbol = it.args[1]

transformExpression(names::Vector{Symbol}, expr::Symbol, checkNames::Bool) = !checkNames ? expr : ((expr in names) ? Expr(:($), expr) : expr)
transformExpression(names::Vector{Symbol}, expr::Expr, ::Bool) = transformExpression(names, Val(expr.head), expr.args)
transformExpression(names::Vector{Symbol}, ::Val{:call}, args::Vector) = Expr(:quote, Expr(:call, [transformExpression(names, arg, true) for arg in args]...))

macro rule(before, after)
    @assert Meta.isexpr(before, :call) "only f(x...) expr allowed"
    before::Expr

    derF = :derivativeFunction
    funcType = before.args[1]
    args = before.args[2:end]

    argNames = args .|> extractArgName

    requiredD = AdjointMapType()
    after = collectAdjoints(requiredD, after)




    definitions = [Expr(:(=), sym, Expr(:call, :derivative, :__derivativeVariable, transformExpression(argNames, expr, false))) for (expr, sym) in requiredD]
    push!(definitions, :(return @generateBase($after)))
    funcSymbol = Expr(:quote, funcType)
    # @show requiredD
    return quote
        simplify(::typeof($funcType), $(args...)) = Expr(:call, $funcSymbol, $(argNames...))


        function derivativeFunction(::typeof($funcType), __derivativeVariable, $(args...))
            $(definitions...)
            return nothing

        end
    end |> esc
end
end

var"@rule" = DefineRuleMacro.var"@rule"
# using .DefineRuleMacro