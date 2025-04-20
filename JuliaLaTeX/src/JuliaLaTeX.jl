Core.eval(Main, :(wasJuliaLatex = false))
Main.wasJuliaLatex = @isdefined JuliaLaTeX
module JuliaLaTeX

include("utils/init.jl")
using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames, PrettyTables
using Unitful.DefaultSymbols


@save_exported export @Lr_str, @byRow, @init_constants, @init_formulas, @substitute,
    calcWith, inlineConstAndVars,
    dataToLaTeX, table2datax,
    process_greek, substitute,
    Constant, Formula, register!, reset_list!, constants2LaTeX, formulas2LaTeX
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
        UnitSystem.SI.convertToPreferred(quantity)
    end
end

function toBaseUnitStrip(quantity::Unitful.AbstractQuantity)::Number
    toBaseUnit(quantity) |> ustrip |> float
end

function toBaseUnitStrip(quntity::Number)::Number
    quntity
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

include("cacl.jl")
include("latex.jl")
include("postlatex.jl")
include("formula.jl")
include("constant.jl")
include("calculation.jl")

function toBaseUnit(expr::Evaluatable)
    UnitSystem.SI.convertToPreferred(expr.inlineWithUnits|>eval)
end



end