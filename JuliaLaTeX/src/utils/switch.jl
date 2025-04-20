
macro switch(expr)
    @assert expr.head == :call
    @assert expr.args[1] == :(=>)
    value = expr.args[2]


    body = expr.args[3]

    prevSum = quote
        local ___value___ = $value
    end
    startBody = prevSum
    ifSym = :if
    # println(string(expr))
    for arg in body.args
        @assert typeof(arg)==Expr
        arg.head==:parameters && continue
        @assert arg.args[1] == :(=>) string(arg)

        ifStmt = if arg.args[2] == :_
            Expr(:block, arg.args[3])
        else
            Expr(ifSym, Expr(:call, :(==), :___value___, arg.args[2]), arg.args[3])
        end

        push!(prevSum.args, ifStmt)
        prevSum = ifStmt
        ifSym = :elseif
    end
    
    # Expr(:block,startBody)|>Base.remove_linenums! |> string|>println
    return esc(Expr(:block,startBody))

end

