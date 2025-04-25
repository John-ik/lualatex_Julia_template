

reload_using(targetModule::Module, sourceModule::Module) = begin
    local list
    if isdefined(sourceModule, :__exported__)
        list = [:($n = $sourceModule.$n) for n in sourceModule.__exported__]
    else
        list = [:($n = $sourceModule.$n) for n in names(sourceModule; all = true, imported = true) if Base.isexported(sourceModule, n)]
    end
    Core.eval(targetModule, Expr(:block, list...))
end


macro safe_using(expr)
    @assert false "Allowed only 'using' expression "
end
macro safe_using(expr::Expr)
    @assert expr.head == :using "Allowed only 'using' expression"#= 
    expr = expr.args[1]
    @assert expr.head == :. "Expected 'using .X'"
    @assert expr.args[1] == :. "Expected 'using .X'"
    m = Core.eval(__module__, expr.args[2])
    body = Expr(:block)
    for symbol in m.__exported__
        push!(body.args, Expr(:(=), symbol, Expr(:., expr.args[2], QuoteNode(symbol))))
    end
    return esc(body) =#
    block = Expr(:block)
    wasUsing = false
    for arg in expr.args
        # @show arg
        @assert Meta.isexpr(arg, :.)
        #if !Meta.isexpr(arg, :.)
        if arg.args[1]!=:.
            if wasUsing
                push!(block.args[end].args, arg)
            else
                push!(block.args, Expr(:using, arg))
            end

            wasUsing = true
            continue
        end
        wasUsing = false

        push!(block.args, Expr(:call, reload_using, __module__, length(arg.args) == 2 ? arg.args[2] : Expr(arg.args...)))
    end
    return esc(block)
end


macro save_exported(expr)
    @assert false "Allowed only 'export' expression "
end
macro save_exported(expr::Expr)
    @assert Meta.isexpr(expr, :export) "Allowed only 'export' expression"
    return esc(Expr(:block, expr,
        Expr(:(=), :__exported__, expr.args),
    ))
end