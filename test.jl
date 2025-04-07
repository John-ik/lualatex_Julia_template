#!/bin/env julia

#jl import Pkg; Pkg.add(url="https://github.com/John-ik/lualatex_Julia_template", subdir="JuliaLaTeX")
#jl Pkg.add(["LaTeXStrings", "Unitful", "UnitfulLatexify", "Latexify","LaTeXDatax"])
# import Pkg;
# import Pkg; Pkg.add(url="file:///"*(@__DIR__)*"", subdir="JuliaLaTeX")

# include("setupDependencies.jl"); DependencyInstaller.initDependencies();

include("JuliaLaTeX/src/JuliaLaTeX.jl") #hide
using .JuliaLaTeX   #hide

#jl using JuliaLaTeX
using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames  #hide
import CSV
import Unitful.DefaultSymbols    #hide
° = Unitful.DefaultSymbols.°
import Statistics;
mean = Statistics.mean;   #hide

reset_list!(Constant)
reset_list!(Formula)
reset_list!(Calculation)


const π=pi
const r_a = 15u"mm"
const r_k = 7u"mm"
const n_0 = 1800u"one"
# Space is important, just for now, to separate expression and unit
@alias const μ_0 = (4 * π * (10^(-7))) u"H/m"

const theta_U = 0.375u"V"
const theta_I = 0.01u"A"
const theta_R = 1u"mm"

R_formula = :((r_a - r_k) / 2)
const R = Core.eval(@__MODULE__, R_formula)

register!(
    Constant("радиус катода", :r_k),
    Constant("радиус анода", :r_a),
    Constant("число витков на единицу длины", :n_0),
    Constant("магнитная постоянная", :μ_0),
    Constant("Систематическая погрешность вольтметра", "\\theta_U", theta_U),
    Constant("Систематическая погрешность амперметра", "\\theta_I", theta_I),
    Constant("Систематическая погрешность длины", "\\theta_R", theta_R),
)
constants2LaTeX("gitignore/test/consts.tex")

# JuliaLaTeX.formulaList=Vector{Formula}[]
# JuliaLaTeX.constantList=Vector{Constant}[]

em = :((2 * U) / (μ_0^2 * R^2 * n_0^2 * I_c^2))



# theta_em = :(em * (theta_U/U + (2theta_I)/I_c))

# JuliaLaTeX.constantAliases[:em]=:(e/m)
# dependsOn=JuliaLaTeX.dependsOn

register!(
    Formula("Радиус кривизны траектории электрона", "R", "R", R_formula),
    Formula("Удельный заряд электрона", "\\frac{e}{m}", :em),
    # dependsOn(Formula("Cистематической погрешность удельный заряд электрона", "\\theta_{\\frac{e}{m}}", :theta_em),:em=>:(e/m))
)
formulas2LaTeX("gitignore/test/formulas.tex")

I = [75, 90, 120] * u"mA"
α_1 = [30.5, 36, 43.5]°
α_2 = [30, 34.5, 41.5]°


macro labaPath(path)
    :("gitignore/1/" * $path)
end


# u10 = CSV.read(@labaPath("data/10.csv"), DataFrame)
# u14 = CSV.read(@labaPath("data/14.csv"), DataFrame)


dataToCalc = [
    (0.9u"A", 10u"V"),
    (0.9u"A", 14u"V")
]

data= DataFrame(U=getindex.(dataToCalc,2),I_c=getindex.(dataToCalc,1))

# calcEm=dataToCalc.|> x-> calcWith(em,:I=>x.first,:U=>x.second)



transform!(data,
    @byRow ((I_c, U) -> calcWith(em, :I_c => I_c, :U => U) |> eval) => :em
)
register!(
    Calculation([:I_c, :U], em, :em)
)

dataToLaTeX("gitignore/test/data_table.tex", data)

table2datax("gitignore/test/datax.tex", data, "table")
calculation2datax("gitignore/test/datax.tex", data, "a")

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