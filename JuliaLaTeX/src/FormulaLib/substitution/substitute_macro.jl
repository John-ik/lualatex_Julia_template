
macro substitute(formulaExpr, args...)
    transformArg(arg) = arg
    function transformArg(arg::QuoteNode)
        typeof(arg.value) != Symbol && (return arg)
        return Expr(:call, :(=>), arg, arg.value)
    end
    return esc(Expr(:call, :substitute, formulaExpr, [transformArg(arg) for arg in args]...))
end