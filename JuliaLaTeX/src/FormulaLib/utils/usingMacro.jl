macro usingMacro(expr)
    @assert false "Allowed only using expressions"
end
macro usingMacro(expr::Expr)
    @assert Meta.isexpr(expr, :using) "Allowed only using expressions"
    expr = expr.args[1]
    @assert expr.head == :. "Expected 'using .X'"
    @assert expr.args[1] == :. "Expected 'using .X'"
    m = Core.eval(__module__, expr.args[2])
    body = Expr(:block)
    for symbol in names(m; all = true)
        startswith(string(symbol),'#') && continue
        push!(body.args, Expr(:(=), symbol, Expr(:., expr.args[2], QuoteNode(symbol))))
    end
    return esc(body)
end
