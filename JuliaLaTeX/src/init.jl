
include("utils/init.jl")
println("\n", @__FILE__, "{")

eval_module()::Module = Main



using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, DataFrames, PrettyTables
using Unitful.DefaultSymbols

#= Main.@timeEachUsing =#

#= Main.@timeEachUsing =#
println("}", @__FILE__, "\n\n")

@save_exported export @Lr_str, @byRow, @init_constants, @init_formulas, @substitute,
    inlineConstAndVars,
    dataToLaTeX, table2datax,
    substitute,
    Constant, Formula, reset!, constants2LaTeX, formulas2LaTeX
# export  @Lr_str, @test, process_greek, substitute

import Unitful

if !Main.wasJuliaLatex
    Core.eval(Main, :(UnitfulLatexify_PrevF = 0))
    Main.UnitfulLatexify_PrevF = last(methods(Latexify.Latexify.apply_recipe, Tuple{Unitful.AbstractQuantity}))
end
@latexrecipe function f(
    q::T; unitformat=:mathrm, siunitxlegacy=false
) where {T<:Unitful.AbstractQuantity}
    operation := :*
    if unitformat === :mathrm || siunitxlegacy
        return Main.UnitfulLatexify_PrevF(q; :unitformat => unitformat, :siunitxlegacy => siunitxlegacy)
    end
    env --> :raw
    return Expr(:latexifymerge, q.val, "\\unit{", UnitfulLatexify.NakedUnits(unit(q)), "}") #= "}{", =#
end


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


function toBaseUnit(quantity::Unitful.AbstractQuantity)::Unitful.AbstractQuantity
    if dimension(quantity) == NoDims
        quantity |> float
    else
        UnitSystem.SI.toPreferred(quantity)
    end
end

function toBaseUnitStrip(quantity)::Number
    toBaseUnit(quantity) |> ustrip |> float
end

function inlineConstants(expr::Expr)
    return inlineConstAndVars(expr;
        mapper=(v, s) -> begin
            !(typeof(v) <: Number) ? s :
            JuliaLaTeX.aliasUnwrap(JuliaLaTeX.toBaseUnitStrip(v), s)
        end,
        m=Main
    )[1]
end


# include("DerivativeLib/init.jl")
# @usingMacro using .DerivativeLib
include("reset_system.jl") #= @namedTime  =#
include("cacl.jl") #= @namedTime  =#
include("latex.jl") #= @namedTime  =#

include("formula.jl") #= @namedTime  =#
include("constant.jl") #= @namedTime  =#
include("datax.jl") #= @namedTime  =#

println()
println()
function toBaseUnit(expr::Evaluatable)
    try
        UnitSystem.SI.toPreferred(Core.eval(Main, expr.inlineWithUnits))
    catch e
        b = IOBuffer()
        show(b, "text/plain", expr)
        error(String(take!(b)), "\n ", e)
    end
end

