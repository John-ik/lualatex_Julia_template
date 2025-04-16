

DisplayRef = ValRef{:(:)}
InlineRef = ValRef{:($)}
DisplayInlineRef = ValRef{Symbol(raw"$:")}

resolveReferences(expr, m::Module) = expr
resolveReferences(expr::Expr, m::Module) = resolveReferences(Val(expr.head), expr, m)

resolveReferences(::Val, expr::Expr, m::Module) = Expr(expr.head, [resolveReferences(x, m) for x in expr.args]...)

resolveReferences(::Val{:$}, expr::Expr, m::Module) = begin
    toEval = expr.args[1]
    if typeof(toEval) == QuoteNode
        v = Core.eval(m, toEval.value)
        return Expr(:quote, DisplayInlineRef(processReference(expr.args[1], v)))
    end
    v = Core.eval(m, toEval)

    Expr(:quote, InlineRef(processReference(expr.args[1], v)))
end

resolveReferences(expr::QuoteNode, m::Module) = begin
    v = Core.eval(m, expr.value)
    Expr(:quote, DisplayRef(processReference(expr.value, v)))
end

processReference(name, value) = value
processReference(name::Symbol, value::Number) = (name, name, value)