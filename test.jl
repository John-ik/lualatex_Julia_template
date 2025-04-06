#!/bin/env julia

#jl import Pkg; Pkg.add(url="https://github.com/John-ik/lualatex_Julia_template", subdir="JuliaLaTeX")
#jl Pkg.add(["LaTeXStrings", "Unitful", "UnitfulLatexify", "Latexify","LaTeXDatax"])
# import Pkg;
# import Pkg; Pkg.add(url="file:///"*(@__DIR__)*"", subdir="JuliaLaTeX")

# include("setupDependencies.jl"); DependencyInstaller.initDependencies();

include("JuliaLaTeX/src/JuliaLaTeX.jl") #hide
using .JuliaLaTeX   #hide

#jl using JuliaLaTeX
using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames, CSV  #hide
import Unitful.DefaultSymbols    #hide
° = Unitful.DefaultSymbols.°
import Statistics; mean = Statistics.mean;   #hide


const N = 36u"one"
const R = 20u"cm"
const v = 50u"Hz"
const U = 12u"V"
const K̇ = 4.5e-7u"1/m"

register!(
    Constant("число витков", "N", N),
    Constant("радиус", "R", R),
    Constant("частота", Lr"\nu", v),
    Constant("напряжение", "U", U),
    Constant("коэффицент установки", Lr"K\dot", K̇)
)
constants2LaTeX("gitignore/test/consts.tex")

H = :(I * N / (2R * tan(α)))
register!(
    Formula("Бла-бла", "h", "H", H)
)
formulas2LaTeX("gitignore/test/formulas.tex")

I = [75, 90, 120]*u"mA"
α_1 = [30.5, 36, 43.5]°
α_2 = [30, 34.5, 41.5]°
data = DataFrame(I=I, α_1=α_1, α_2=α_2)

transform!(data, AsTable(r"α") => ByRow(mean) => :ᾱ)


latexify(H)

transform!(data,
    @byRow ((I, ᾱ) -> calcWith(H, :I => I, :α => ᾱ) |> eval) => :H
)

dataToLaTeX("gitignore/test/data_table.tex", data)

# CSV.write("gitignore/test/data.csv", 
#     data
#     ; 
#     # header=[
#     #         string(raw"$", latexify(name; env=:raw), ",\\;", latexify(unit(u)), raw"$")
#     #             for (name, u) in zip(names(data), data[1, :])
#     #         ],
#     delim="|",
#     transform=(col, val)-> val |> JuliaLaTeX.toBaseUnit
# )

# H_mean = mean(data[:, :H])
# for (u, i) in 
# LaTeXDatax.datax("datax.tex", "f($(Protocol[1]),$(Protocol[2]))", "123"; permissions="a")