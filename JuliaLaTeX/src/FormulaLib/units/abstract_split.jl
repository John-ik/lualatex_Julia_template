




splitExpressionWithUnit(any)::Tuple = tuple(any, nothing);
splitExpressionWithUnit(any::Expr)::Tuple = splitExpressionWithUnit(Val(any.head), any);
splitExpressionWithUnit(T::Val{:call}, any::Expr)::Tuple = splitExpressionWithUnit(T, Val(any[1]), any)

function splitExpressionWithUnit(T::Val, any::Expr)::Tuple
    return defaultSplitExprWithUnit(T, any)
end

function defaultSplitExprWithUnit(::Val, any::Expr)::Tuple
    # newArgs = any.args .|> splitExpressionWithUnit
    newArgs = map( splitExpressionWithUnit,any.args)
    # maximum(newArgs.|> length)==1 && return Expr(any.head,any.args)|>tuple
    # return tuple(Expr(any.head,filter[findfirst(!isnothing, a) for a in newArgs ]...),findfirst(!isnothing, newArgs.|> last) )
    unit = nothing
    for arg in newArgs
        arg[2] !== nothing && (unit = arg[2])
    end
    return tuple(Expr(any.head, map(first,newArgs)...), unit)
end


splitExpressionWithUnit(T::Val{:call}, func::Val, any::Expr)::Tuple = defaultSplitExprWithUnit(T, any)