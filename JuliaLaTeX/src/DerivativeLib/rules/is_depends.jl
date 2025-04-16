
is_depends_on(expr::Number, x::Symbol) = false
is_depends_on(expr::Symbol, x::Symbol) = expr == x
is_depends_on(expr::Expr, x::Symbol) = begin
    for arg in expr.args
        is_depends_on(arg, x) && return true
    end
    return false
end
