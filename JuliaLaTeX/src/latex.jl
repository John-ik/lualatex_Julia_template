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
    mkpath(dirname(filename))
    open(filename, permissions) do io
        dataToLaTeX(io, data)
    end
end

function dataToLaTeX(io::IO, data::DataFrame)
    set_default(unitformat=:siunitx, fmt=FancyNumberFormatter(4))
    local ret = pretty_table(io, 
        Tables.matrix(data) .|> JuliaLaTeX.toBaseUnitStrip .|> latexify .|> LatexCell
        ; backend = Val(:latex), alignment=:c, 
        header = [
            string(raw"$", latexify(name; env=:raw), ",\\;", latexify(unit(u)), raw"$")
                for (name, u) in zip(names(data), data[1, :])
            ] .|> LatexCell
    )
    reset_default()
    return ret
end


function table2datax(data::DataFrame, name::String)
    io = IOContext(IOBuffer())
    table2datax(io, data, name)
    return String(take!(io.io))
end
function table2datax(filename::String, data::DataFrame, name::String, permissions::String="w")
    mkpath(dirname(filename))
    open(filename, permissions) do io
        table2datax(io, data, name, permissions)
    end
end
function table2datax(io::IO, data::DataFrame, name::String, permissions::String="w")
    set_default(unitformat=:siunitx, fmt=FancyNumberFormatter(4), env=:raw)
    indexes = ["$name[$(names(data, coli)[1]),$rowi]" for coli=1:ncol(data) for rowi=1:nrow(data)]
    values  = [data[rowi, coli] for coli=1:ncol(data) for rowi=1:nrow(data)] .|> toBaseUnit .|> latexify
    LaTeXDatax.datax(io, indexes, values; permissions)
    reset_default()
end