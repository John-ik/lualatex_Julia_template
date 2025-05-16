
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
    data_to_LaTeX_table, table2datax,
    substitute,
    Constant, Formula, reset!, constants2LaTeX, formulas2LaTeX,
    eval_with_units
# export  @Lr_str, @test, process_greek, substitute

import Unitful


if !isdefined(Main, :____was__JuliaLatex)
    Core.eval(Main, quote
        ____was__JuliaLatex = true
        UnitfulLatexify_PrevF = 0
    end
    )
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
include("calculation/init.jl") #= @namedTime  =#
include("latex.jl") #= @namedTime  =#

include("formula.jl") #= @namedTime  =#
include("constant.jl") #= @namedTime  =#
include("convert/init.jl") #= @namedTime  =#
include("rounding/init.jl") #= @namedTime  =#

#region rounding

UnitSystem.extract_value(pm::PlusMinusResult) = PlusMinusResult(pm.int_value, pm.int_theta, pm.tail_size, pm.e10, nothing)
UnitSystem.extract_unit(pm::PlusMinusResult) = pm.unit

function toBaseUnit(pm::PlusMinusResult)
    pref=UnitSystem.SI.preferredUnit(pm.unit)
    pm.unit == pref && return pm
    ±(float(pm)...,pref,pm.e10)
end

@extra_datax function f(io::IO, ::String, col_name::Symbol, row_index::Int, data::PlusMinusResult)
    tail_ = tail_size(data)
    value_ = print_fraction_with_e10(data.int_value, tail_ - 1)
    theta_ = print_fraction_with_e10(data.int_theta, tail_ - 1)
    function wrap(x)
        data.e10==0 && return x
        data.e10==1 && return Expr(:call,:*,x,10)
        return Expr(:call,:*,x,Expr(:call,:^,10,data.e10))
    end
    
    unit_expr= data.unit===nothing ? "" : latexify(data.unit;env=:raw,unitformat=:siunitx)
    
    LaTeXDatax.printkeyval(io,
        "pm/value/$col_name[$row_index]", 
        string(latexify(wrap(value_); env=:raw),unit_expr)
    )
    LaTeXDatax.printkeyval(io,
        "pm/theta/$col_name[$row_index]", 
        string(latexify(wrap(theta_); env=:raw),unit_expr)
    )
    LaTeXDatax.printkeyval(io,
        "pm/both/$col_name[$row_index]", 
        latexify(data; env=:raw,unitformat=:siunitx)
    )
end
#endregion

println()
println()
function eval_with_units(expr::Number)
    return expr
end
function eval_with_units(expr::Evaluatable)
    try
        UnitSystem.applyUnitTo(Core.eval(eval_module(), expr.inlineWithUnits), expr.unit)
    catch e
        error("expr cannot be evaluated '$expr': ", e)
    end
end

function toBaseUnit(expr::Evaluatable)
    try
        UnitSystem.SI.toPreferred(Core.eval(eval_module(), expr.inlineWithUnits))
    catch e
        b = IOBuffer()
        show(b, "text/plain", expr)
        error(String(take!(b)), "\n ", e)
    end
end

