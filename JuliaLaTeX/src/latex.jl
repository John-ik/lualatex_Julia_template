@doc raw"""
    L"..."

Creates a `LaTeXString` and is equivalent to `raw_latexstring(raw"...")`, except that
`%$` can be used for interpolation.

```jldoctest
julia> Lr"x = \sqrt{2}"
L"x = \sqrt{2}"

julia> Lr"x = %$(sqrt(2))"
L"x = 1.4142135623730951"
```
"""
macro Lr_str(str::String)
    expr = LaTeXStrings.var"@L_str"(__source__, __module__, str)
    expr.args[1].args[1] = GlobalRef(@__MODULE__, :raw_latexstring)
    expr
end
@doc raw"""
    raw_latexstring(args...)
    
Creates a `LaTeXString` object directly from the input arguments

"""
function raw_latexstring(s...)
    return raw_latexstring(string(s...))
end

function raw_latexstring(s::String)
    return LaTeXString(s)
end

