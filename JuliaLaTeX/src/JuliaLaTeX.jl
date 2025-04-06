module JuliaLaTeX

using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames
using Unitful.DefaultSymbols

export @Lr_str, @test, calcWith, process_greek, substitute
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
    lambda = test.args[2]
    test.args[2] = Expr(:call, :ByRow, lambda)
    l = lambda.args[1].args |> x -> QuoteNode.(x)


    key = Expr(:vect, l...)
    out = Expr(:call, Symbol("=>"), key, test)
    return esc(out)

end

function makeFunction(ex, vars::Pair{Symbol,<:Any}...)
    return Expr(:function,
        Expr(:tuple, first.(vars)...),
        Expr(:block, ex)
    )
end
function addVariables(ex, vars::Pair{Symbol,<:Real}...)
    pairToExpr((k, v)) = Expr(:local, Expr(:(=), k, v))

    block = Expr(:block, (vars .|> pairToExpr)..., ex)
    return block
end

function get_caller_module(stackLevel::Int=4)
    linfo = stacktrace()[stackLevel].linfo
    typeof(linfo) == Core.MethodInstance && return linfo.def.module
    return Main
end
function calcWith0(evalModule::Module, ex, vars::Pair{Symbol,<:Any}...)
    code = makeFunction(ex, vars...)
    f = Core.eval(evalModule, code)
    return Base.invokelatest(f, (last.(vars))...)
end
calcWith(ex, vars::Dict{Symbol,<:Any}) = calcWith0(get_caller_module(), ex, vars...)
calcWith(ex, vars::Pair{Symbol,<:Any}...) = calcWith0(get_caller_module(), ex, vars...)

calcWith(ex, vars::Pair{Symbol,<:Real}...) = Core.eval(get_caller_module(),addVariables(ex, vars...))
# calcWith(ex::Number, vars::Pair{Symbol,<:Number}...) = ex
calcWith(ex, vars::Dict{Symbol,<:Real}) = calcWith0(get_caller_module(), ex, vars...)

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

include("postlatex.jl")

end