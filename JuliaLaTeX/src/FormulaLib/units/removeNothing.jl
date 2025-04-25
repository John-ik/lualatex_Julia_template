
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
    println(string(expr))
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



removeNothing(t) = t
removeNothing(t::Expr) = removeNothing(Val(t.head), t)
removeNothing(::Val{:call}, t::Expr) = removeNothingCall(Val(t.args[1]), map(removeNothing,t.args[2:end])...)
removeNothing(::Val, t::Expr) = Expr(t.head, map(removeNothing,t.args)...)



removeNothingCall(::Val{T}, args...) where {T} = Expr(:call, T, args...)|>x->(println(x);x)

filterNumber(f::Function, args)=filter(x->!(typeof(x)<:Number || typeof(x)==Nothing) || f(x),args)

removeNothingCall(::Val{:*}, args...) = filterNumber(x->!isnothing(x) && !isone(x),args)|> x-> @switch length(x) => {
    0 => nothing,
    1 => x[1],
    _ => Expr(:call, :*, x...);
} 
removeNothingCall(::Val{:+}, args...) = filterNumber(x->!isnothing(x) && !iszero(x),args)|> x-> @switch length(x) => {
    0 => 0,
    1 => x[1],
    _ => Expr(:call, :+, x...);
}
removeNothingCall(::Val{:/}, args...) =  args[2]===nothing ? nothing : Expr(:call,:/, something(args[1],1),args[2])
removeNothingCall(::Val{:\}, args...) =  args[1]===nothing ? nothing : Expr(:call,:\,args[1], something(args[2],1))
