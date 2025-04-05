module JuliaLaTeX

using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames
using Unitful.DefaultSymbols

export  @Lr_str, @test, calcBy, process_greek, substitute
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
    return esc(out)

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

include("postlatex.jl")

end