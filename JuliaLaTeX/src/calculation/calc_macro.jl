
macro calculation(expr::Expr)
    @assert expr.head == :block "only blocks allowed"
    expr = wrap_calc_eq!(copy(expr))
    res = Expr(:block,
        Expr(:(=), self_calculation_name, Expr(:call, :Calculation)),
        Expr(:let,
            Expr(:(=), Symbol("self"), self_calculation_name),
            expr
        ),
        self_calculation_name
    )
    esc(res)
end
@save_exported export @calculation


self_calculation_name = :___local_map___

@inline wrap_calc_eq!(@nospecialize(expr)) = expr
@inline wrap_calc_eq!(expr::Expr) = wrap_calc_eq!(Val(expr.head), expr)
@inline wrap_calc_eq!(@nospecialize(::Val), expr::Expr) = expr
@inline wrap_calc_eq!(::Val{:(=)}, expr::Expr) = make_calc_eq_expr!(expr.args[1], expr)

@inline make_calc_eq_expr!(name::Expr, expr::Expr) = expr
@inline make_calc_eq_expr!(name::T, expr::Expr) where {T} = error(LazyString("Type '", T, "' cannot be used as name in calculation expression"))
@inline make_calc_eq_expr!(name::Symbol, expr::Expr) = Expr(:(=), Expr(:ref, self_calculation_name, QuoteNode(name)), expr)
@inline make_calc_eq_expr!(name::String, expr::Expr) = begin
    expr.args[1] = Expr(:ref, self_calculation_name, QuoteNode(Symbol(name)))
    expr
end

@inline wrap_calc_eq!(::@unionVal(:block, :if, :elseif), expr::Expr) = begin
    for i in eachindex(expr.args)
        expr.args[i] = wrap_calc_eq!(expr.args[i])
    end
    expr
end
@inline wrap_calc_eq!(::@unionVal(:while, :for, :let), expr::Expr) = begin
    expr.args[2] = wrap_calc_eq!(expr.args[2])
    expr
end