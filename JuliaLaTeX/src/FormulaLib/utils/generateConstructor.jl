macro all_arg_constructor(expr)
    @assert Meta.isexpr(expr, :struct) "Only struct allowed here"
    name = expr.args[2]
    body = expr.args[3]

    fieldWithTypes = []
    fieldNames = []
    for node in body.args
        !(Meta.isexpr(node, :(::)) || typeof(node) == Symbol) && continue
        push!(fieldWithTypes, node)
        typeof(node) == Symbol ? push!(fieldNames, node) : push!(fieldNames, node.args[1])
    end

    push!(body.args, Expr(:(=),
        Expr(:call, name, fieldWithTypes...),
        Expr(:call, :new, fieldNames...),
    ))
    return esc(expr)
end