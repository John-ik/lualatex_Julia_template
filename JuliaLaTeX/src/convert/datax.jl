supported_datax_types_union = Union{DataFrame,Calculation}

import LaTeXDatax

store_datax(io::IO, (k, v)::Pair{String,Any}) = LaTeXDatax.printkeyval(io, k, v)
function store_datax(io::IO, d::Vector{Pair{String,Any}})
    for (k, v) in d
        LaTeXDatax.printkeyval(io, k, v)
    end
end


function table2datax(data::supported_datax_types_union, name::String)
    io = IOContext(IOBuffer())
    table2datax(io, data, name)
    return String(take!(io.io))
end
function table2datax(filename::String, data::supported_datax_types_union, name::String, permissions::String="w")
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
function table2datax(io::IO, data::Calculation, name::String, permissions::String="w")
    set_default(unitformat=:siunitx, fmt=FancyNumberFormatter(4), env=:raw)

    for (col_name::Symbol, list) in data
        list = ensure_iterable(list)
        for (r, v) in enumerate(list)
            key = "$name[$col_name,$r]"
            LaTeXDatax.printkeyval(io, key, toBaseUnit(v))
        end
    end

    for (col_name::Symbol, list) in data
        list = ensure_iterable(list)
        el_type = eltype(list)
        el_type != Evaluatable && continue
        for (r::Int, elem::Evaluatable) in enumerate(list)
            LaTeXDatax.printkeyval(io,
                "calc/$col_name[$r]",
                latexify(elem.displayCalculated; env=:raw)
            )

            f::Formula = Core.eval(eval_module(), col_name)

            d = latexifyDisplayName(f.displayName)
            LaTeXDatax.printkeyval(io,
                "expr/$col_name[$r]",
                latexify(Expr(:(=), LaTeXString(d), elem.displayCalculated); env=:raw)
            )
        end
    end
    reset_default()
end