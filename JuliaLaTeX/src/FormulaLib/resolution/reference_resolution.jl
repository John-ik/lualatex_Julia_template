
DisplayRef = ValRef{:(:)}
InlineRef = ValRef{:($)}
DisplayInlineRef = ValRef{Symbol(raw"$:")}
@enum IgnoreStatus ignoreNoOne ignoreMissing ignoreAll
const default_STATUS_IGNORE = Dict{Symbol, IgnoreStatus}()
const default_REFERENCE_MAP::Dict{Symbol, Union{Base.Callable, Nothing}} = Dict(
    Symbol("") => InlineRef,
    :($) => nothing,
    :(:) => DisplayInlineRef,
    Symbol(raw"$:") => DisplayInlineRef)
@kwdef mutable struct ReferenceResolutionContext
    m::Module
    ignoreReferences::Dict{Symbol, IgnoreStatus} = copy(default_STATUS_IGNORE)
    referenceTypeMap::Dict{Symbol, Union{Base.Callable, Nothing}} = copy(default_REFERENCE_MAP)
end
Base.broadcastable(x::ReferenceResolutionContext)=Ref(x)

resolveReferences(expr, m::Module) = resolveReferences(expr, ReferenceResolutionContext(m = m))
resolveReferences(expr, context::ReferenceResolutionContext) = expr
resolveReferences(expr::Expr, context::ReferenceResolutionContext) = resolveReferences(Val(expr.head), expr, context)

# resolveReferences(v::Val, expr::Expr, context::ReferenceResolutionContext) = error("No impl for $v -> '$expr'")
resolveReferences(::Union{Val{Symbol("'")}, Val{:curly}}, expr::Expr, context::ReferenceResolutionContext) = Expr(expr.head, [resolveReferences(x, context) for x in expr.args]...)
resolveReferences(::Val{:call}, expr::Expr, context::ReferenceResolutionContext) = Expr(expr.head, expr.args[1], [resolveReferences(x, context) for x in expr.args[2:end]]...)
# 

tryResolveReference(type::Symbol, context::ReferenceResolutionContext, expr) = begin
    ignoreType::IgnoreStatus = get(context.ignoreReferences, type, ignoreNoOne)
    (ignoreType == ignoreAll) && return expr
    referenceMaker = context.referenceTypeMap[type]
    referenceMaker === nothing && return expr
    try
        v = evalWithLine(context, expr)
        return Expr(:quote, referenceMaker(processReference(expr, v)))
    catch e
        ignoreType == ignoreNoOne && rethrow(e)
        return expr
    end
end

resolveReferences(::Val{:$}, expr::Expr, context::ReferenceResolutionContext) = begin
    toEval = expr.args[1]
    if typeof(toEval) == QuoteNode
        tryResolveReference(Symbol(raw"$:"), context, toEval.value)
    else
        tryResolveReference(:($), context, toEval)
    end
end

evalWithLine(context::ReferenceResolutionContext, expr) =
    try
        Core.eval(context.m, Expr(:block, @__CUR_LINE__, expr))
    catch e
        error(e)
    end

resolveReferences(expr::Symbol, context::ReferenceResolutionContext) = begin
    tryResolveReference(Symbol(""), context, expr)
end

# 
resolveReferences(expr::QuoteNode, context::ReferenceResolutionContext) = begin
    tryResolveReference(Symbol(":"), context, expr.value)
end

processReference(name, value) = value
processReference(name::Symbol, value::Number) = (name, name, value)