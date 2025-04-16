include("../0_aliases.jl")


function makeFunction(ex::Expression, vars::Pair{Symbol,<:Any}...)
    return Expr(:function,
        Expr(:tuple, first.(vars)...),
        Expr(:block, ex)
    )
end
function addVariables(ex::Expression, vars::Pair{Symbol,<:Any}...)
    pairToExpr((k, v)) = Expr(:local, Expr(:(=), k, v))

    block = Expr(:block, (vars .|> pairToExpr)..., ex)
    return block
end


function get_caller_module(stackLevel::Int=3)
    linfo = stacktrace()[stackLevel+1].linfo
    typeof(linfo) == Core.MethodInstance && return linfo.def.module
    return Main
end
function calcWith0(evalModule::Module, ex, vars::Pair{Symbol,<:Any}...)
    code = makeFunction(ex, vars...)
    f = Core.eval(evalModule, code)
    return Base.invokelatest(f, (last.(vars))...)
end
calcWith(ex, vars::Dict{Symbol,<:Any}) = calcWith0(get_caller_module(), ex, vars...)
calcWith(ex, vars::Pair{Symbol,<:Any}...) = calcWith0(get_caller_module(), ex, vars...)

calcWith(ex, vars::Pair{Symbol,<:Real}...) = Core.eval(get_caller_module(),addVariables(ex, vars...))
# calcWith(ex::Number, vars::Pair{Symbol,<:Number}...) = ex
calcWith(ex, vars::Dict{Symbol,<:Real}) = calcWith0(get_caller_module(), ex, vars...)
