macro import_exported(expr)
    @assert false "Allowed only 'using' expression "
end
macro import_exported(expr::Expr)
    @assert Meta.isexpr(expr, :using) "Allowed only 'using' expression"
    expr = expr.args[1]
    @assert expr.head == :. "Expected 'using .X'"
    @assert expr.args[1] == :. "Expected 'using .X'"
    m = Core.eval(__module__, expr.args[2])
    body = Expr(:block)
    for symbol in m.__exported__
        push!(body.args, Expr(:(=), symbol, Expr(:., expr.args[2], QuoteNode(symbol))))
    end
    return esc(body)
end
macro save_exported(expr)
    @assert false "Allowed only 'export' expression "
end
macro save_exported(expr::Expr)
    @assert Meta.isexpr(expr, :export) "Allowed only 'export' expression"
    return esc(Expr(:block, expr,
        Expr(:(=), :__exported__, expr.args)
    ))


end