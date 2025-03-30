using LaTeXStrings, Latexify, Unitful

function substitute(str::LaTeXString, old_new_s::Pair...)::LaTeXString
    result = LaTeXString(str)
    for (from, to) in old_new_s
        # if its with unit convert to SI and unit strip
        to = isa(to, Unitful.AbstractQuantity) ? (upreferred(to) |> ustrip |> float) : to
        result = replace(result, Regex("(?!<=\\w)\\Q$(latexify(from; env=:raw))\\E(?!=\\w)") => to) |> LaTeXString
    end
    return result
end
