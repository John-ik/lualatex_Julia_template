"""
Analog @L_str but without \$

No character escaping: `Lr"2 \\cdot 2"` is valid
"""
macro Lr_str(str::String)
    LaTeXString(str)
end


function dataToLaTeX(data::DataFrame)
    io = IOContext(IOBuffer())
    dataToLaTeX(io, data)
    return String(take!(io.io))
end

function dataToLaTeX(filename::String, data::DataFrame, permissions::String="w")
    open(filename, permissions) do io
        dataToLaTeX(io, data)
    end
end

function dataToLaTeX(io::IO, data::DataFrame)
    set_default(unitformat=:siunitx, fmt=FancyNumberFormatter(4))
    local ret = pretty_table(io, Tables.matrix(data) .|> JuliaLaTeX.toBaseUnit .|> latexify .|> LatexCell
        ; backend = Val(:latex), alignment=:c, 
        header = [string(raw"$",latexify(name; env=:raw), ",\\;", latexify(unit(u)), raw"$") for (name, u) in zip(names(data), data[1, :])] .|>LatexCell)
    reset_default()
    return ret
end