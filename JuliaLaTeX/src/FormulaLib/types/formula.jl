
mutable struct Formula
    name::Symbol
    displayName::Expression
    expr::Evaluatable
    #= 
        function Formula(name::Symbol,
            displayName::QuoteNode,
            expr::Expression) error(string(name," \ndisplay = ",displayName,"\n eval =",expr)) end =#
    function Formula(name::Symbol,
        @nospecialize(displayName::Union{Expression, QuoteNode}),
        expr::Expression, caller_module::Union{Module, Nothing} = nothing)
        if caller_module === nothing
            stack = stacktrace()[2]
            caller_module = Main
            typeof(stack.linfo) == Core.MethodInstance && (caller_module = stack.linfo.def.module)
        end
        resolveNameContext = ReferenceResolutionContext(m = caller_module)
        resolveNameContext.referenceTypeMap[:($)] = nothing
        resolveNameContext.referenceTypeMap[Symbol(raw"$:")] = nothing
        resolveNameContext.referenceTypeMap[Symbol(raw"")] = nothing
        resolveNameContext.referenceTypeMap[Symbol(raw":")] = DisplayRef

        displayName = @switch displayName => {
            typeof(_) == QuoteNode => displayName.value;
            Meta.isexpr(_, :quote) => displayName.args[1]
            ; _ => displayName;
        }
        displayName = inlineResolved(resolveReferences(displayName, resolveNameContext), :display)
        return new(name, displayName, Evaluatable(expr, caller_module))
    end

    function Base.show(io::IO, T::MIME"text/plain", it::Formula)
        print(io, it.name, " = ", it.displayName, " = ")
        return Base.show(IOContext(io, :compact => true), T, it.expr)
    end
    Base.show(io::IO, it::Formula) = print(io, "Formula(", it.name, ")")
end
using Markdown: Markdown

description(m::Module, it::Formula)::Union{Markdown.MD, Nothing} = begin
    b = Base.Docs.Binding(m, it.name)
    Base.Docs.hasdoc(b) ? Base.Docs.doc(b) : nothing
end

extractKey(it::Formula, ::Val{:display}) = it.displayName
extractKey(it::Formula, ::Val{:inlineWithUnits}) = Expr(:call, UnitSystem.applyUnitTo, it.expr.inlineWithUnits, it.expr.unit)
extractKey((it,)::InlineRef{Formula}, ::Val{:inlineValue}) = extractKey(it, Val(:inlineValue))

extractKey((it,)::Union{DisplayInlineRef{Formula}}, ::Val{:displayCalculated}) = ValRef(:calcLater, #=  InlineRef{Formula},  =#
    Expr(:call, (v) -> begin
            UnitSystem.extract_value(UnitSystem.SI.toPreferred(v))
        end, it.expr.inlineWithUnits),
)

extractKey((it,)::InlineRef{Formula}, v::Val{:displayCalculated}) = extractKey(it, v)
extractKey(it::Formula, ::Val{:displayCalculated}) = begin
    # return it.expr.displayCalculated
    expr::Evaluatable = it.expr
    displayCalculated::Expression = expr.displayCalculated
    (expr.unit === nothing) && return displayCalculated
    convExpr = UnitSystem.SI.convertExpr(expr.unit)::Union{Nothing, Base.Callable}
    convExpr === nothing && displayCalculated
    return convExpr(displayCalculated)
end
extractKey(it::Formula, ::Val{:base}) = it.name
extractKey(it::Formula, ::Val{:inlineValue}) = begin
    # converter = UnitSystem.SI.convertExpr(it.expr.unit)
    # converter === nothing ? it.expr.inlineValue : Expr(:call,,it.expr.inlineValue)
    Expr(:call, x -> begin
            UnitSystem.extract_value(UnitSystem.SI.toPreferred(UnitSystem.applyUnitTo(x, it.expr.unit)))
        end, it.expr.inlineValue)
end

@assertImplementInlineOptions(Formula)