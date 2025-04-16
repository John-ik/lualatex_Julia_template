include("../0_aliases.jl")


# function resolveSymbols(ex::Expression,resolver::Function)
# resolver(::Symbol)::Union{Nothing, Any}
# end

resolveSymbols(ex::Symbol, resolver::Function) = something(resolver(ex), ex)
resolveSymbols(ex::Any, resolver::Function) = ex
#TODO should we resolve operation symbols?
resolveSymbols(ex::Expr, resolver::Function) = Expr(ex.head, [resolveSymbols(arg, resolver) for arg in ex.args]...)



substituteVarsAndEnvConsts(ex::Expression, m::Module) =
    resolveSymbols(ex, x => try
        Core.eval(m, x)
    catch nothing
    end)

function substituteVarsAndEnvConsts0(
    ex::Expr,
    vars::Union{Dict{Symbol,Union{<:Number,Expr,Symbol}},Nothing}=nothing;
    mapper::Function=(x, k) -> x,
    m::Union{Module,Nothing}=nothing
)::Vector
    local newArgs = []
    for arg in ex.args
        for res in inlineConstAndVars(arg, vars; stacklevel=stacklevel + 1, mapper=mapper, m=m)
            push!(newArgs, res)
        end
    end
    return [Expr(ex.head, newArgs...)]
end
function inlineConstAndVars(
    ex::Symbol,
    vars::Union{Dict{Symbol,Union{<:Number,Expr,Symbol}},Nothing}=nothing; mapper::Function=(x, k) -> x,
    m::Module
)::Vector

    nothing !== vars && haskey(vars, ex) && return [mapper(vars[ex], ex);]
    m = m === nothing ? get_caller_module(stacklevel + 2) : m
    if isdefined(m, ex)
        v = Core.eval(m, ex)
        if typeof(v) <: Number || typeof(v) <: Expr || typeof(v) <: Symbol
            return [mapper(v, ex);]

        end
    end
    return [ex]
end
function inlineConstAndVars(ex::Expr, vars::Union{Dict,Nothing}=nothing;
    stacklevel::Int=0, mapper::Union{Function,Nothing}=nothing, m::Union{Module,Nothing}=nothing)::Vector
    return inlineConstAndVars(ex, Dict{Symbol,Union{<:Number,Expr,Symbol}}(vars); stacklevel=stacklevel + 1)
end
function inlineConstAndVars(ex::Expression, vars=nothing; mapper=nothing, m=nothing)::Vector
    return [ex]
end