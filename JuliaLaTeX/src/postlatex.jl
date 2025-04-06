function toBaseUnit(quantity::Unitful.AbstractQuantity)::Number
    upreferred(quantity) |> ustrip |> float
end

function toBaseUnit(quntity::Number)::Number
    quntity
end

"""
Substitute pairs where key and value be latexified, if key is LaTeXString no.

# Example
```
result = substitute("U / I", :U => 10, "I" => "1 \\cdot 2") # "\\frac{10}{1 \\cdot 2}"
```
"""
function substitute(str::LaTeXString, old_new_s::Pair...; kwargs_latex...)::LaTeXString
    set_default(env=:raw, fmt=FancyNumberFormatter(4))
    result = LaTeXString(str)
    for (from, to) in old_new_s
        # if its with unit convert to SI and unit strip
        if ! (typeof(to) <: AbstractString)
            to = toBaseUnit(to)
        end
        result = replace(result, Regex("(?!<=\\w)\\Q$(latexify(from; kwargs_latex...))\\E(?!=\\w)") => latexify(to; kwargs_latex...)) |> LaTeXString
    end
    reset_default()
    return result
end

substitute(str::AbstractString, old_news_S::Pair...; kwargs_latex...)::LaTeXString = substitute(latexify(str; kwargs_latex...), old_news_S...; kwargs_latex...)


"""
Replace greek name of vars to LaTeX greek. Theta -> ``\\Theta``
"""
function process_greek(str::LaTeXString)::LaTeXString
    str
end
