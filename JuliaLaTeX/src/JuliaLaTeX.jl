module JuliaLaTeX

using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames
using Unitful.DefaultSymbols

export @Lr_str, @test, calcWith, process_greek, substitute
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

end