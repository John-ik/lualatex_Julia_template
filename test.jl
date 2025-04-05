#!/bin/env julia

#jl import Pkg; Pkg.add(url="https://github.com/John-ik/lualatex_Julia_template", subdir="JuliaLaTeX")
#jl Pkg.add(["LaTeXStrings", "Unitful", "UnitfulLatexify", "Latexify","LaTeXDatax"])

include("JuliaLaTeX/src/JuliaLaTeX.jl") #hide
using .JuliaLaTeX   #hide

#jl using JuliaLaTeX
using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames, CSV  #hide
import Unitful.DefaultSymbols    #hide
°=Unitful.DefaultSymbols.°
import Statistics; mean = Statistics.mean   #hide


const N = 36u"one"
const R = 20u"cm"
const ν = 50u"Hz"
const U = 12u"V"
const K̇ = 4.5e-7u"1/m"


I = [75, 90, 120]*u"mA"
α_1 = [30.5, 36, 43.5]°
α_2 = [30, 34.5, 41.5]°
data = DataFrame(I=I, α_1=α_1, α_2=α_2)

transform!(data, AsTable(r"α") => ByRow(mean) => :ᾱ)

H = :( I * N / (2R * tan(α)) )

latexify(H)

interpolate_from_dict(ex::Expr, dict) = Expr(ex.head, interpolate_from_dict.(ex.args, Ref(dict))...)
interpolate_from_dict(ex::Symbol, dict) = get(dict, ex, ex)
interpolate_from_dict(ex::Any, dict) = ex
macro test(test::Expr)
    # TODO assetations

    lambda=test.args[2]
    test.args[2]=Expr(:call,:ByRow,lambda)
    l = lambda.args[1].args|>x->QuoteNode.(x)
    

    key=Expr(:vect, l...)
    out=Expr(:call,Symbol("=>"),key,test)
    return out

end
@test ((Ias, α) -> Ias*2 |> eval)=>  :H
macro calcByRow(exprs...)
    for expr in collect(exprs)
        @show expr
    end
end

transform!(data, 
    [:I, :ᾱ] => ByRow((I, ᾱ) -> (interpolate_from_dict(H, Dict(:I=>I, :α=>ᾱ))) |> eval) => :H,
    @test ((I, ᾱ) -> (interpolate_from_dict(H, Dict(:I=>I, :α=>ᾱ))) |> eval) => :H1
    )

# H_mean = mean(data[:, :H])
# for (u, i) in 
# LaTeXDatax.datax("datax.tex", "f($(Protocol[1]),$(Protocol[2]))", "123"; permissions="a")