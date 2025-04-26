
struct HandleFormulaMacroContext
    __module__::Module
    __source__::LineNumberNode
    wrapped::Union{Base.Callable, Symbol, Nothing}
end

handleFormulaMacro(ctx::HandleFormulaMacroContext, s::Symbol, expr::Expr) = handleFormulaMacro(ctx, Val(s), expr)
handleFormulaMacro(ctx::HandleFormulaMacroContext, expr::Expr) = handleFormulaMacro(ctx, Val(expr.head), expr)
handleFormulaMacro(::HandleFormulaMacroContext, @nospecialize(::Val), expr::Expr) = expr
handleFormulaMacro(::HandleFormulaMacroContext, expr) = expr
function handleFormulaMacro(ctx::HandleFormulaMacroContext, ::Val{:block}, expr::Expr)
    for i in 1:length(expr.args)
        expr.args[i] = handleFormulaMacro(ctx, expr.args[i])
    end

    return expr
end

handleFormulaMacro(ctx::HandleFormulaMacroContext, ::Val{:(macrocall)}, expr::Expr) = begin
    # @show :macrocall, expr.args .|> string
    if expr.args[1] == Symbol("@escape")

        amountOfElement = expr.args[3:end]
        length(amountOfElement) == 1 && return amountOfElement[1]
        b = Expr(:block)
        println("Escape: ")
        b.args = amountOfElement
        return b
    end
    string(expr.args[1]) != "Core.var\"@doc\"" && return expr
    expr.args[4] = handleFormulaMacro(ctx, expr.args[4])
    expr
end
function handleFormulaMacro(ctx::HandleFormulaMacroContext, ::Val{:(=)}, expr::Expr)
    value = expr.args[2]
    name = localName = expr.args[1]
    localValue = value
    if typeof(value) == Expr && value.head == :(=)
        localName = value.args[1]
        localName = typeof(localName) == Symbol ? QuoteNode(localName) : Expr(:quote, localName)
        localValue = value.args[2]
    end
    # expr.args[2] = :(($localName, $localValue))
    expr.args[2] = wrap_formula_make(ctx.wrapped, Expr(:call, :Formula,
        map(QuoteNode ∘ Base.remove_linenums!, (name, localName, localValue))...,
        Expr(:kw, :caller_module, ctx.__module__))
    )
    return expr

end

wrap_formula_make(::Nothing, expr::Expr) = expr
wrap_formula_make(it::Base.Callable, expr::Expr) = it(expr)
wrap_formula_make(it::Symbol, expr::Expr) = Expr(:call, it, expr)

variable_modifiers = [:const, :global, :local, :outer]
function handleFormulaMacro(ctx::HandleFormulaMacroContext, ::@unionVal($variable_modifiers), expr::Expr)
    inner = expr
    outer = expr
    while typeof(inner) == Expr && inner.head in variable_modifiers
        outer = inner
        inner = inner.args[1]
    end
    typeof(inner) != Expr && return expr
    outer.args[1] = handleFormulaMacro(ctx, Val(inner.head), inner)
    return expr
end



macro formulas(@nospecialize(expr))
    return esc(expr)
end
macro formulas(expr::Expr)
    return esc(handleFormulaMacro(HandleFormulaMacroContext(__module__, __source__, nothing), expr.head, expr))
end

