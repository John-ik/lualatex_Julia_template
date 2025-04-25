

unpackEqualExpr(expr::Symbol) = (expr, expr)
function unpackEqualExpr(expr::Union{Expr, Number})

    # @assert equal.head==:(=) "expected expr like 'nameExpression = someExpression'"
    typeof(expr) <: Expr && expr.head == :(=) && return (expr.args[1], expr.args[2])


end

extractKey(it, ::Val{:this}) = it


inlineResolved(@nospecialize(expr::Any), T::Symbol) = inlineResolved(expr, Val{T}())
inlineResolved(expr::Expr, T::Symbol) = inlineResolved(Val(expr.head), expr, Val{T}())
inlineResolved(@nospecialize(expr), @nospecialize(T::Val)) = expr
inlineResolved(expr::Expr, @nospecialize(T::Val)) = inlineResolved(Val(expr.head), expr, T)

supportedInlineOptions = [
    :base, #= :inlineValue,  =#:inlineWithUnits, :display, :displayCalculated,
]
inlineResolved(@nospecialize(::Val), expr::Expr, T::@unionVal $supportedInlineOptions) = Expr(expr.head, [inlineResolved(it, T) for it in expr.args]...)

function ensureImplementInlineOptions(type::Type)::Tuple{Bool, Vector{Symbol}}
    missingOptions = []
    for option in supportedInlineOptions
        method = methods(extractKey, Tuple{type, Val{option}})[1]
        method.file == @__FILE__() && push!(missingOptions, option)
    end
    return length(missingOptions) == 0, missingOptions
end
macro assertImplementInlineOptions(type::Union{Expr, Symbol, Type})
    return esc(quote
        begin
            local isImpl = ensureImplementInlineOptions($type)
            @assert isImpl[1] "missing options: " * string(isImpl[2])
        end
    end)
end

inlineResolved(::Val{:quote}, expr::Expr, T::@unionVal($supportedInlineOptions)) = extractKey(expr.args[1], T)
extractKey(it, key::Symbol) = extractKey(it, Val(key))
extractKey(it, key) = error(string("No implementation for '", it, "' typeof ", typeof(it), " for type ", key))



for option in supportedInlineOptions
    # AllRef = Union{DisplayRef, InlineRef, DisplayInlineRef}
    optionW = Expr(:quote, option)
    for ref in [DisplayRef, InlineRef, DisplayInlineRef]
        eval(quote
            extractKey((it,)::$ref, val::Val{$optionW}) = extractKey(it, val)
        end)
    end

end

extractKey((it,)::DisplayRef, val::Val{:inlineValue}) = extractKey(it, Val(:base))
# extractKey((it,)::Union{DisplayRef, DisplayInlineRef}, val::Val{:inlineWithUnits}) = extractKey(it, Val(:base))

extractKey((it,)::InlineRef, val::Val{:displayCalculated}) = extractKey(it, Val(:display))


extractKey(it::Tuple{Symbol, Symbol, <:Number}, ::Val{:base}) = it[1]
extractKey(it::Tuple{Symbol, Symbol, <:Number}, ::Val{:display}) = it[2]
extractKey(it::Tuple{Symbol, Symbol, <:Number}, ::Val{:displayCalculated}) = it[2]
extractKey(it::Tuple{Symbol, Symbol, <:Number}, ::Val{:inlineWithUnits}) = it[3]


