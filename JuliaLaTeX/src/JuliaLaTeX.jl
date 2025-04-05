module JuliaLaTeX
using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax
using Unitful.DefaultSymbols

export  @Lr_str, process_greek, substitute

"""
Analog @L_str but without \$

No character escaping: `Lr"2 \\cdot 2"` is valid
"""
macro Lr_str(str::String)
    LaTeXString(str)
end



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

include("postlatex.jl")

end