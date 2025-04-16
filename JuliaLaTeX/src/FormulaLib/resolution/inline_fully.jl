
inlineAll(expr) = expr
inlineAll(expr::Expr) = inlineAll(Val(expr.head), expr)

inlineAll(expr::Expr) = inlineAll(Val(expr.head), expr)
function inlineAll(::Val, expr::Expr)
    newArgs = []
    isSplit = false
    for it in expr.args
        inlined = inlineAll(it)
        if typeof(it) == typeof(inlined)
            if isSplit
                for i in eachindex(supportedInlineOptions)
                    push!(newArgs[i][2], inlined)
                end
            else
                push!(newArgs, inlined)
            end
            continue
        end
        if !isSplit
            createdArgs = newArgs
            newArgs = similar(Vector{Pair{Symbol, Vector}}, length(inlined))
            for i in eachindex(supportedInlineOptions)
                newArgs[i] = supportedInlineOptions[i] => copy(createdArgs)
                push!(newArgs[i][2], inlined[i][2])
            end
            isSplit = true
        else
            for i in eachindex(supportedInlineOptions)
                push!(newArgs[i][2], inlined[i][2])
            end
        end
    end
    !isSplit && return Expr(expr.head, newArgs...)
    return [args[1] => Expr(expr.head, args[2]...) for args in newArgs]
end
inlineAll(::Val{:quote}, expr::Expr) = [option => extractKey(expr.args[1], option) for option in supportedInlineOptions]
inlineAll2(expr) = [option => inlineResolved(expr,option) for option in supportedInlineOptions]
