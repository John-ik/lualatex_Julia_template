module JuliaLaTeX
using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames, PrettyTables, Tables
using Unitful.DefaultSymbols

export  @Lr_str, @test, calcBy, process_greek, substitute, dataToLaTeX
# export  @Lr_str, @test, process_greek, substitute

"""
Analog @L_str but without \$

No character escaping: `Lr"2 \\cdot 2"` is valid
"""
macro Lr_str(str::String)
    LaTeXString(str)
end

macro test(test::Expr)
    # TODO assetations

    lambda=test.args[2]
    test.args[2]=Expr(:call,:ByRow,lambda)
    l = lambda.args[1].args|>x->QuoteNode.(x)
    

    key=Expr(:vect, l...)
    out=Expr(:call,Symbol("=>"),key,test)
    return out

end

calcBy(ex::Expr, dict) = Expr(ex.head, calcBy.(ex.args, Ref(dict))...)
calcBy(ex::Symbol, dict) = get(dict, ex, ex)
calcBy(ex::Any, dict) = ex



function Base.show(io::IO, ::MIME"text/markdown", s::LaTeXString)
    start = "```math\n"
    theend= "\n```"
    m = match(r"^\$([^\$]+)\$$", s.s) 
    if m === nothing
        output = s.s
    else
        output = m.captures[1]
    end
    print(io, start * output * theend)
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

include("postlatex.jl")

end