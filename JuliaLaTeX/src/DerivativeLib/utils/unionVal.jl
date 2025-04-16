macro unionVal(expr::Union{Symbol,QuoteNode,Number,Bool}...)
    esc(:(Union{$((expr .|> (x -> :(Val{$x})))...)}))
end
macro unionVal(expr::Expr)
    @assert expr.head == :$ "expected '\$(variable)'"

    inner = expr.args[1]
    reference = Core.eval(__module__, :(($inner)))
    # @show reference
    # print(__source__," ",typeof(__source__))
    var"@unionVal"(__source__, __module__, (reference.|>QuoteNode)...)
end

