using LaTeXStrings, Latexify, Unitful

function toBaseUnit(quantity::Unitful.AbstractQuantity)::Number
    upreferred(quantity) |> ustrip |> float
end

function toBaseUnit(quntity::Number)::Number
    quntity
end

function substitute(str::LaTeXString, old_new_s::Pair...; kwargs...)::LaTeXString
    result = LaTeXString(str)
    for (from, to) in old_new_s
        # if its with unit convert to SI and unit strip
        to = toBaseUnit(to)
        result = replace(result, Regex("(?!<=\\w)\\Q$(latexify(from; kwargs...))\\E(?!=\\w)") => latexify(to; kwargs...)) |> LaTeXString
    end
    
    return result
end

substitute(str::AbstractString, old_news_S::Pair...; kwargs...)::LaTeXString = substitute(latexify(str; kwargs...), old_news_S...; kwargs...)