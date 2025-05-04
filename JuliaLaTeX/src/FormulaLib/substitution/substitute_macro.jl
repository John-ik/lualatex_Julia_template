
macro substitute(formulaExpr, args...)
    transformArg(arg) = arg
    function transformArg(arg::QuoteNode)
        typeof(arg.value) != Symbol && (return arg)
        return Expr(:call, :(=>), arg, arg.value)
    end
    return esc(Expr(:call, :substitute, formulaExpr, [transformArg(arg) for arg in args]...))
end

macro substitute!(formula_expr, args...)
    return Base.Broadcast.__dot__(var"@substitute"(__source__, __module__, formula_expr, args...))
end
@save_exported export @substitute!,@substitute