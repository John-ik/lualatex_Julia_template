#!/bin/env julia

#jl import Pkg; Pkg.add(url="https://github.com/John-ik/lualatex_Julia_template", subdir="JuliaLaTeX")
#jl Pkg.add(["LaTeXStrings", "Unitful", "UnitfulLatexify", "Latexify","LaTeXDatax"])
# import Pkg;
# import Pkg; Pkg.add(url="file:///"*(@__DIR__)*"", subdir="JuliaLaTeX")

# include("setupDependencies.jl"); DependencyInstaller.initDependencies();

include("JuliaLaTeX/src/JuliaLaTeX.jl") #hide
JuliaLaTeX.@import_exported using .JuliaLaTeX   #hide

#jl using JuliaLaTeX
using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames  #hide
import CSV
import Unitful.DefaultSymbols    #hide
° = Unitful.DefaultSymbols.°
import Statistics;
mean = Statistics.mean;   #hide

reset_list!(Constant)
reset_list!(Formula)


JuliaLaTeX.UnitSystem.SI.preferredUnit(::typeof(dimension(u"C/kg")))=u"C/kg"

const π = pi
@init_constants begin
    "радиус анода"
    r_a = 15u"mm"    #= const =#
    "радиус катода"
    r_k = 7u"mm"    #= const =#
    "число витков на единицу длины"
    n_0 = 1800u"1/m"    #= const =#
    "магнитная постоянная"
    μ_0 = (4 * π * (10^(-7))) * u"H/m"    #= const =#
    "Систематическая погрешность вольтметра"
    θ_U = 0.375u"V"    #= const =#
    "Систематическая погрешность амперметра"
    θ_I = 0.01u"A"    #= const =#
    "Систематическая погрешность длины"
    θ_R = 1u"mm"    #= const =#

end
macro ignore(it)
    return it
end
@init_formulas begin

    "Радиус кривизны траектории электрона"
    R = (r_a - r_k) / 2    #= const =#
    @ignore begin
        R.expr.inlineWithUnits |> eval |> JuliaLaTeX.setCalculated(R.expr)
    end
    "Удельный заряд электрона"
    em = e / m = (2 * $U) / (μ_0^2 * R^2 * n_0^2 * $I_c^2)    #= const =#
    "Систематической погрешность удельный заряд электрона"
    thetaem = θ_{:em} = $:em * (θ_U / $U + (2θ_I) / $I_c + (2θ_R) / R)    #= const =#

end

constants2LaTeX("gitignore/test/consts.tex")

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
    (0.96u"A", 14u"V")
]

data = DataFrame(U=getindex.(dataToCalc, 2), I_c=getindex.(dataToCalc, 1))

# calcEm=dataToCalc.|> x-> calcWith(em,:I=>x.first,:U=>x.second)



transform!(data,
    @byRow ((I_c, U) -> @substitute(em, :I_c, :U)) => :em
)
transform!(data,
    @byRow ((em, I_c, U) -> @substitute(thetaem, :I_c, :U)) => :thetaem
)
# register!(
#     Calculation([:I_c, :U], em),
#     Calculation([:em, :I_c, :U], thetaem)
# )

# dataToLaTeX("gitignore/test/data_table.tex", data)

table2datax("gitignore/test/datax.tex", data, "table")
# calculation2datax("gitignore/test/datax.tex", data, "a")

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