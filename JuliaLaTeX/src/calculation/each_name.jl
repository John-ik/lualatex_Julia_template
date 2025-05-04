
wrap_eq_len(a::Expr, b::Expr) = Expr(:call, :(==), a, b)
# wrap_eq_len(a::Symbol, b::Symbol) = Expr(:(==), wrap_len(a), wrap_len(b))
wrap_len(a::Symbol) = Expr(:call, :length, a)
map_to_get_index(a::Symbol) = Expr(:(=), a, Expr(:ref, a, :__i__))

macro esc(it)
    # QuoteNode(Expr(:escape, esc(Expr(:($),it))))
    # Expr(:(:),(Expr(:call, :esc, esc(it))))
    # esc(esc(it))

    Expr(:call, :esc, esc(it))
end

macro each_name(lambda_expr::Expr)
    @assert lambda_expr.head == :-> "allowed only lambda expressions"
    args_t = lambda_expr.args[1]
    names = typeof(args_t) == Symbol ? [args_t] : args_t.args
    @assert !isempty(names) "must be at least one name"
    body = lambda_expr.args[2]


    first = names[1]
    result = Expr(:block,
        length(names) == 1 ? __source__ : Expr(:macrocall, Symbol("@assert"), __source__, foldr(wrap_eq_len, map(wrap_len, names)), " Arrays has different length "),
        Expr(:(=), :__vector__, Expr(:call, :Vector, :undef, wrap_len(first))),
        Expr(:for, Expr(:(=), :__i__, Expr(:call, :eachindex, first)),
            Expr(
                :(=),
                Expr(:ref, :__vector__, :__i__),
                Expr(
                    :let,
                    Expr(:block, map(map_to_get_index, names)...),
                    body
                )
            )),
        :__vector__
    )
    esc(result)
end

@save_exported export @each_name


