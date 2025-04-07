macro byRow(pair::Expr)
    # TODO assetations
    lambda = pair.args[2]
    pair.args[2] = Expr(:call, :ByRow, lambda)
    l = lambda.args[1].args |> x -> QuoteNode.(x)


    key = Expr(:vect, l...)
    out = Expr(:call, Symbol("=>"), key, pair)
    return esc(out)

end

function makeFunction(ex, vars::Pair{Symbol,<:Any}...)
    return Expr(:function,
        Expr(:tuple, first.(vars)...),
        Expr(:block, ex)
    )
end
function addVariables(ex, vars::Pair{Symbol,<:Real}...)
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


function inlineConstAndVars(
    ex::Expr, 
    vars::Union{Dict{Symbol,Union{<:Number,Expr,Symbol}},Nothing}=nothing;

    stacklevel::Int=0,
    mapper::Function=(x,k)->x,
    m::Union{Module,Nothing}=nothing
    )::Vector
    local newArgs=[]
    for arg in ex.args
        for res in inlineConstAndVars(arg,vars;stacklevel=stacklevel+1,mapper=mapper,m=m)
            push!(newArgs,res)
        end
    end
    return [Expr(ex.head,newArgs...)]
end
function inlineConstAndVars(
    ex::Symbol, 
    vars::Union{Dict{Symbol,Union{<:Number,Expr,Symbol}},Nothing}=nothing;
    
    stacklevel::Int=0,
    mapper::Function=(x,k)->x,
    m::Union{Module,Nothing}=nothing
    )::Vector
    
     nothing!== vars && haskey(vars,ex) && return [mapper(vars[ex],ex);]
     m= m===nothing ? get_caller_module(stacklevel+2) : m
     if isdefined(m, ex) 
        v= Core.eval(m,ex)
        if typeof(v)<:Number || typeof(v)<:Expr || typeof(v)<:Symbol
            return [mapper(v,ex);]

        end
     end
     return [ex]
end
function inlineConstAndVars(ex::Expr, vars::Union{Dict,Nothing}=nothing;
    stacklevel::Int=0,mapper::Union{Function,Nothing}=nothing,m::Union{Module,Nothing}=nothing)::Vector
    return inlineConstAndVars(ex,Dict{Symbol,Union{<:Number,Expr,Symbol}}(vars);stacklevel=stacklevel+1)
end
function inlineConstAndVars(ex, vars=nothing;
    stacklevel=0,mapper=nothing,m=nothing)::Vector
    return [ex]
end