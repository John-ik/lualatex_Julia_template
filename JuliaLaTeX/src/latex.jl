"""
Analog @L_str but without \$

No character escaping: `Lr"2 \\cdot 2"` is valid
"""
macro Lr_str(str::String)
    LaTeXString(str)
end

#= 
function dataToLaTeX(data::DataFrame)
    io = IOContext(IOBuffer())
    dataToLaTeX(io, data)
    return String(take!(io.io))
end =#

function dataToLaTeX(filename::String, data::DataFrame, @nospecialize(nameAliases::Pair...); permissions::String="w")
    mkpath(dirname(filename))
    open(filename, permissions) do io
        dataToLaTeX(io, data, nameAliases...)
    end
end

function dataToLaTeX(io::IO, data::DataFrame, @nospecialize(nameAliases::Pair...))
    set_default(unitformat=:siunitx, fmt=FancyNumberFormatter(4))
    nameAliases = Dict(nameAliases...)
    @show
    local ret = pretty_table(io,
        [LatexCell(latexify(
            if typeof(v) == Evaluatable
                UnitSystem.extractValueFrom(
                    UnitSystem.applyUnitTo(Core.eval(eval_module(),v.inlineWithUnits), v.unit)
                )
            else
                JuliaLaTeX.toBaseUnitStrip(v)
            end
        )) for v in Tables.matrix(data)]
        ; backend=Val(:latex), alignment=:c, vlines=:all,
        header=[
            string(raw"$",
                latexify(get(nameAliases, name, name); env=:raw),
                ",\\;",
                if typeof(u) == Evaluatable
                    # UnitSystem.applyUnitTo(u.inlineWithUnits |> eval,u.unit)
                    latexify(u.unit)
                else
                    latexify(UnitSystem.extractUnitFrom(u))
                end,
                raw"$")
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

    for r in 1:nrow(data)
        for c in 1:ncol(data)
            key = "$name[$(names(data, c)[1]),$r]"
            LaTeXDatax.printkeyval(io, key, toBaseUnit(data[r, c]))
        end
    end

    for c in 1:ncol(data)
        col = data[!, c]
        typeof(col) != Vector{Evaluatable} && continue
        form = names(data, c)[1]
        for r in 1:nrow(data)
            LaTeXDatax.printkeyval(io,
                "calc/$form[$r]",
                latexify(data[r, c].displayCalculated; env=:raw)
            )

            f::Formula = Core.eval(eval_module(), Symbol(form))
            d = latexifyDisplayName(f.displayName)
            LaTeXDatax.printkeyval(io,
                "expr/$form[$r]",
                latexify(Expr(:(=), LaTeXString(d), data[r, c].displayCalculated); env=:raw)
            )
        end
    end
    reset_default()
end