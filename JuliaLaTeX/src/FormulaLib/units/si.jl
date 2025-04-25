module SI
preferredUnit(::Nothing) = nothing
preferredUnit(::Missing) = missing
preferredUnit(::Main.STD_NUMBERS) = nothing
function toPreferred(value::Main.STD_NUMBERS)
    return value
end

"""
    convertExpr(any)=convertExpr(any,preferredUnit(any))

    Returns f(x)->Expr(__, x, __) thats construct a conversion to SI type from variable x
    
    Returns nothing if no conversion is required
    
    # Examples
    ```julia-repl
    julia> convertExpr(0)
    nothing
    ```
    
    # Examples Unitful
    ```julia-repl
    julia> convertExpr(10u"m")
    nothing
    julia> convertExpr(10u"mm")(10)
    10*0.001
    ```
"""
convertExpr(value)::Union{Function, Nothing} = convertExpr(value, preferredUnit(value))
convertExpr(::Nothing, ::Nothing)::Union{Function, Nothing} = nothing
convertExpr(value::Number, targetUnit::Union{Missing, Nothing})::Union{Function, Nothing} = identity

end
