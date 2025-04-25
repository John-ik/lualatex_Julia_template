macro unionVal(expr::Union{Symbol,QuoteNode,Number,Bool}...)
    esc(:(Union{$([:(Val{$x})  for x in expr]...)}))
end
macro unionVal(expr::Expr)
    @assert expr.head == :$ "expected '\$(variable)'"

    inner = expr.args[1]
    reference = Core.eval(__module__, :(($inner)))
    # @show reference
    # print(__source__," ",typeof(__source__))
    @switch typeof(reference)=>{
        _<:Vector || _<:Tuple => var"@unionVal"(__source__, __module__, map(QuoteNode,reference)...)
        _=> var"@unionVal"(__source__, __module__, QuoteNode(reference))
    }
end

