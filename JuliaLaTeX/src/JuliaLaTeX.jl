module JuliaLaTeX

using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames, PrettyTables
using Unitful.DefaultSymbols

export @Lr_str, @byRow, calcWith, 
    dataToLaTeX, table2datax,
    process_greek, substitute,
    Constant, register!, constants2LaTeX
# export  @Lr_str, @test, process_greek, substitute



function Base.show(io::IO, ::MIME"text/markdown", s::LaTeXString)
    start = "```math\n"
    theend = "\n```"
    m = match(r"^\$([^\$]+)\$$", s.s)
    if m === nothing
        output = s.s
    else
        output = m.captures[1]
    end
    print(io, start * output * theend)
end

include("cacl.jl")
include("latex.jl")
include("postlatex.jl")
include("constant.jl")

end