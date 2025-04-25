


handleFormulaMacro(s::Symbol, expr::Expr) = handleFormulaMacro(Val(s), expr)
handleFormulaMacro(expr::Expr) = handleFormulaMacro(Val(expr.head), expr)
handleFormulaMacro(::Val, expr::Expr) = expr
handleFormulaMacro(expr) = expr
function handleFormulaMacro(::Val{:block}, expr::Expr)
    for i in 1:length(expr.args)
        expr.args[i] = handleFormulaMacro(expr.args[i])
    end

    return expr
end

handleFormulaMacro(::Val{:(macrocall)}, expr::Expr) = begin
    # @show :macrocall, expr.args .|> string
    string(expr.args[1]) != "Core.var\"@doc\"" && return expr
    expr.args[4] = handleFormulaMacro(expr.args[4])
    expr
end
function handleFormulaMacro(::Val{:(=)}, expr::Expr)
    value = expr.args[2]
    name = localName = expr.args[1]
    localValue = value
    if typeof(value) == Expr && value.head == :(=)
        localName = value.args[1]
        localName = typeof(localName) == Symbol ? QuoteNode(localName) : Expr(:quote, localName)
        localValue = value.args[2]
    end
    # expr.args[2] = :(($localName, $localValue))
    expr.args[2] = Expr(:call, :Formula, map(QuoteNode ∘ Base.remove_linenums!,(name, localName, localValue))...)
    return expr

end
variable_modifiers = [:const, :global, :local, :outer]
function handleFormulaMacro(::@unionVal($variable_modifiers), expr::Expr)
    inner = expr
    outer = expr
    while typeof(inner) == Expr && inner.head in variable_modifiers
        outer = inner
        inner = inner.args[1]
    end
    typeof(inner) != Expr && return expr
    outer.args[1] = handleFormulaMacro(Val(inner.head), inner)
    return expr
end



macro formulas(expr)
    typeof(expr) != Expr && return esc(expr)
    return esc(handleFormulaMacro(expr.head, expr))
end

