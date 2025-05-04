struct WhereBlockWrapper{T <: Union{Vector{Expr}, Nothing}}
    blocks::T
end

(wrapper::WhereBlockWrapper{Vector{Expr}})(it) = Expr(:where, it, wrapper.blocks...)
(::WhereBlockWrapper{Nothing})(it) = it
nothing_wrapper = WhereBlockWrapper(nothing)

macro all_arg_constructor(expr)
    @assert Meta.isexpr(expr, :struct) "Only struct allowed here"
    name = expr.args[2]
    new_call = :new

    where_wrapper::WhereBlockWrapper = nothing_wrapper

    if Meta.isexpr(name, :curly)
        old = copy(name)
        name = old.args[1]
        new_call = old
        new_call.args[1] = :new

        where_block = [
            begin
                it = new_call.args[i]
                new_call.args[i] = it.args[1]
                it
            end
            for i in 2:length(new_call.args) if Meta.isexpr(new_call.args[i], :(<:))
        ]

        if !isempty(where_block)
            where_wrapper = WhereBlockWrapper(where_block)
        end

    elseif Meta.isexpr(name, :where)
        old2 = copy(name)
        name = old2.args[1]
        if Meta.isexpr(name, :curly)
            old = copy(name)

            name = Expr(old.args[1])
            new_call = old
            new_call.args[1] = :new
        end
        where_wrapper = WhereBlockWrapper(old2.args[2:end] |> Vector)
        # old2.args[1]=name
        # name=old2
    end


    body = expr.args[3]

    fieldWithTypes = []
    fieldNames = []
    for node in body.args
        !(Meta.isexpr(node, :(::)) || typeof(node) == Symbol) && continue
        push!(fieldWithTypes, node)
        typeof(node) == Symbol ? push!(fieldNames, node) : push!(fieldNames, node.args[1])
    end

    push!(body.args, Expr(:(=),
        where_wrapper(Expr(:call, name, fieldWithTypes...)),
        Expr(:call, new_call, fieldNames...),
    ))
    return esc(expr)
end


@macroexpand @all_arg_constructor mutable struct Evaluatable{T <: Union{Nothing, Int}}
    it::T
end