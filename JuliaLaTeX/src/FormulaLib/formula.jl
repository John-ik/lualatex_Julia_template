
@all_arg_constructor mutable struct Evaluatable
    base::Expression
    # inlineValue::Expression
    inlineWithUnits::Expression
    display::Expression
    displayCalculated::Expression
    raw::Expression
    resolved::Expression
    unit::Any

    function Evaluatable(expr::Expression, m::Union{Module, Nothing} = nothing)
        if m === nothing
            stack = stacktrace()[2]
            typeof(stack.linfo) == Core.MethodInstance && (m = stack.linfo.def.module)
        end
        expr, unit = UnitSystem.splitExpressionWithUnit(expr)
        while typeof(expr) == Expr && expr.head == :block && length(expr.args) == 1
            expr = expr.args[1]
        end
        resolved = resolveReferences(expr, m)
        return new(
            inlineResolved(resolved, :base),
            # inlineResolved(resolved, :inlineValue),
            inlineResolved(resolved, :inlineWithUnits),
            inlineResolved(resolved, :display),
            inlineResolved(resolved, :displayCalculated),
            expr,
            resolved,
            UnitSystem.extractValueUnitFrom(try
                Core.eval(m, unit)
            catch e
                error(e)
            end)[2],# for 1/m
        )
    end
    function Base.show(io::IO, ::MIME"text/plain", it::Evaluatable)
        Base.summary(io, it)
        println(io)
        fields = it |> displayFields
        io = IOContext(io, :typeinfo => Base.eltype(fields))
        return Base.print_array(io, fields)
    end
    Base.show(io::IO, it::Evaluatable) = print(io, it.raw, " # unit = ", it.unit)
end

function Base.copy(it::Evaluatable)
    return Evaluatable([getproperty(it, f) for f in fieldnames(Evaluatable)]...)
end

setCalculated(it::Evaluatable) = number -> (setCalculated(it, number); number)
function setCalculated(it::Evaluatable, number::Number)
    (value, unit) = UnitSystem.extractValueUnitFrom(number)
    it.displayCalculated = value
    it.unit = unit
    return nothing
end

mutable struct Formula
    name::Symbol
    displayName::Expression
    expr::Evaluatable
    #= 
        function Formula(name::Symbol,
            displayName::QuoteNode,
            expr::Expression) error(string(name," \ndisplay = ",displayName,"\n eval =",expr)) end =#
    function Formula(name::Symbol,
        displayName::Union{Expression, QuoteNode},
        expr::Expression)
        stack = stacktrace()[2]
        m = Main
        typeof(stack.linfo) == Core.MethodInstance && (m = stack.linfo.def.module)
        resolveNameContext = ReferenceResolutionContext(m = m)
        resolveNameContext.referenceTypeMap[:($)] = nothing
        resolveNameContext.referenceTypeMap[Symbol(raw"$:")] = nothing
        resolveNameContext.referenceTypeMap[Symbol(raw"")] = nothing
        resolveNameContext.referenceTypeMap[Symbol(raw":")] = DisplayRef
        if typeof(displayName) == QuoteNode
            displayName = inlineResolved(resolveReferences(displayName.value, resolveNameContext), :display)
        elseif typeof(displayName) != Expr
            displayName = inlineResolved(resolveReferences(displayName, resolveNameContext), :display)
        elseif displayName.head == :quote
            displayName = inlineResolved(resolveReferences(displayName.args[1], resolveNameContext), :display)
        else
            displayName = inlineResolved(resolveReferences(displayName, resolveNameContext), :display)
        end
        return new(name, displayName, Evaluatable(expr, m))
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
            UnitSystem.extractValueUnitFrom(UnitSystem.SI.convertToPreferred(v))[1]
        end, it.expr.inlineWithUnits),
)

extractKey((it,)::InlineRef{Formula}, v::Val{:displayCalculated}) = extractKey(it, v)
extractKey(it::Formula, ::Val{:displayCalculated}) = begin
    expr = it.expr
    displayCalculated = expr.displayCalculated
    expr.unit === nothing && return displayCalculated
    convExpr = UnitSystem.SI.getConvertExpr(expr.unit)
    convExpr === nothing && displayCalculated
    return convExpr(displayCalculated)
end
extractKey(it::Formula, ::Val{:base}) = it.name
extractKey(it::Formula, ::Val{:inlineValue}) = begin
    # converter = UnitSystem.SI.getConvertExpr(it.expr.unit)
    # converter === nothing ? it.expr.inlineValue : Expr(:call,,it.expr.inlineValue)
    Expr(:call, x -> begin
            UnitSystem.extractValueUnitFrom(UnitSystem.SI.convertToPreferred(UnitSystem.applyUnitTo(x, it.expr.unit)))[1]
        end, it.expr.inlineValue)
end

@assertImplementInlineOptions(Formula)