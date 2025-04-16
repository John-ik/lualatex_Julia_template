module SI
preferredUnit(::Nothing) = nothing
preferredUnit(::Missing) = missing
preferredUnit(::Main.STD_NUMBERS) = nothing
function convertToPreferred(value::Main.STD_NUMBERS)
    return value
end

"""
    getConvertExpr(any)=getConvertExpr(any,preferredUnit(any))

    Returns f(x)->Expr(__, x, __) thats construct a conversion to SI type from variable x
    
    Returns nothing if no conversion is required
    
    # Examples
    ```julia-repl
    julia> getConvertExpr(0)
    nothing
    ```
    
    # Examples Unitful
    ```julia-repl
    julia> getConvertExpr(10u"m")
    nothing
    julia> getConvertExpr(10u"mm")(10)
    10*0.001
    ```
"""
getConvertExpr(value)::Union{Function, Nothing} = getConvertExpr(value, preferredUnit(value))
getConvertExpr(::Nothing, ::Nothing)::Union{Function, Nothing} = nothing
getConvertExpr(value::Number, targetUnit::Union{Missing, Nothing})::Union{Function, Nothing} = identity

end
