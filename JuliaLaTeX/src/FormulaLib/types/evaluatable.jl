@all_arg_constructor mutable struct Evaluatable
    # base::Expression
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
        # inlineAll(resolved)
        return new(
            ##=expr,=# inlineResolved(resolved, :base),
            # inlineResolved(resolved, :inlineValue),
            inlineResolved(resolved, :inlineWithUnits),            #=expr,=#
            inlineResolved(resolved, :display),            #=expr,=#
            inlineResolved(resolved, :displayCalculated),            #=expr,=#
            expr,
            resolved,
            UnitSystem.extractUnit(try
                Core.eval(m, unit)
            catch e
                error(e)
            end),# for 1/m
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

setCalculated(it::Evaluatable) = Base.Fix1(setCalculated, it)
function setCalculated(it::Evaluatable, number::Number)
    (value, unit) = UnitSystem.extractValueUnitFrom(number)
    it.displayCalculated = value
    it.unit = unit
    return number
end