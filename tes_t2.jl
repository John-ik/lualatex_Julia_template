#!/bin/env julia

#jl import Pkg; Pkg.add(url="https://github.com/John-ik/lualatex_Julia_template", subdir="JuliaLaTeX")
#jl Pkg.add(["LaTeXStrings", "Unitful", "UnitfulLatexify", "Latexify","LaTeXDatax"])
# import Pkg;
# import Pkg; Pkg.add(url="file:///"*(@__DIR__)*"", subdir="JuliaLaTeX")

# include("setupDependencies.jl"); DependencyInstaller.initDependencies();

macro timeEachUsing(stmt::Expr)
    # Expr(:block, [Expr(:macrocall, Symbol("@time"), __source__, string(a.args[1]), Expr(:using, a)) for a in stmt.args]...) |> esc
    esc(stmt)
end
macro namedTime(stmt::Expr)
    # esc(Expr(:macrocall, Symbol("@time"), __source__, string(stmt), stmt))
    esc(stmt)
end
@time "JuliaLaTex" include("JuliaLaTeX/src/JuliaLaTeX.jl") #hide
JuliaLaTeX.@safe_using using .JuliaLaTeX   #hide

#jl using JuliaLaTeX

@timeEachUsing (using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax, DataFrames)  #hide
@time "CSV" import CSV
@time "Unitful.DefaultSymbols" import Unitful.DefaultSymbols    #hide
° = Unitful.DefaultSymbols.°
@time "Statistics" import Statistics;
mean = Statistics.mean;   #hide

reset_list!(Constant)
reset_list!(Formula)


JuliaLaTeX.UnitSystem.SI.preferredUnit(::typeof(dimension(u"C/kg"))) = u"C/kg"
# JuliaLaTeX.UnitSystem.SI.preferredUnit(::typeof(u"°")) = u"°"

const π = pi
@init_constants begin
    "Максимальный заряд конденсатора С~(рис.~\\ref{fig:block2})"
    U = 12u"V"

    "Радиус катушки"
    R = 20u"cm"
    "Частота переключения реле П~(рис.~\\ref{fig:block2})"
    ν = 50u"Hz"
    "Кол-во ветков в катушке"
    N = 36
    k = ("\\text{к}")' = 4.5 * 10^-7u"1/m"

    "Систематическая погрешность вольтметра"
    θ_U = 0.4u"V"
    "Систематическая погрешность амперметра"
    θ_I = 0.2u"mA"
    "Систематическая погрешность угла"
    θ_α = 0.5u"°"
    "Систематическая погрешность угла"
    θ_β = 0.5u"°"
end
macro ignore(it)
    return it
end
ctg = cot
tg = tan

@init_formulas begin

    "Радиус кривизны траектории электрона"
    # R = (r_a - r_k) / 2
    @ignore begin
        # R.expr.inlineWithUnits |> eval |> JuliaLaTeX.setCalculated(R.expr)
    end
    "Горизонтальная состовляющая магнитного поля земли"
    H = H_{"\\text{земли}"} = ($I * N * ctg($α)) / 2R * u"A/m"


    # e0 = ε0 = (($:k * 2 * R) / (N * ν)) * (($:H * tg($β)) / (U))
end
JuliaLaTeX.@formulas begin
    thetaH_v = θ_{:H} = $thetaH_v
    H_v = :H = $H_v
end
thetaH_v.displayName = Symbol(JuliaLaTeX.latexifyDisplayName(thetaH_v.displayName))
H_v.displayName = Symbol(JuliaLaTeX.latexifyDisplayName(H_v.displayName))
@init_formulas begin
    "Электрическая постоянная"
    e0 = ε_0 = :k * (2R * :H_v * tg($β)) / (N * ν * U) * u"pF/m"

    "Систематическая погресть для горизонтальной состовляющей магнитного поля земли"
    thetaH = θ_{:H} = :H * ((2θ_α) / sin(2 * $α) + θ_I / $I) * u"A/m"

    "Систематическая погресть для электрической постоянной"
    thetaE = θ_{:e0} = :e0 * (:thetaH_v / :H_v + θ_β / $β + θ_U / U) * u"pF/m"



end

macro labaPath_str(path::String)
    "gitignore/2/datax/" * path
end


@time "constants" constants2LaTeX(labaPath"consts.tex")
@time "formulas" formulas2LaTeX(labaPath"formulas.tex")



# u10 = CSV.read(@labaPath("data/10.csv"), DataFrame)
# u14 = CSV.read(@labaPath("data/14.csv"), DataFrame)





data = DataFrame(
    I=[75, 95, 110] * u"mA",
    α_1=[27, 33, 36]°,
    α_2=[29, 35, 39]°
)

# calcEm=dataToCalc.|> x-> calcWith(em,:I=>x.first,:U=>x.second)

transform!(data,
    @byRow ((α_1, α_2) -> (α_1 + α_2) / 2) => :α
)
dataToLaTeX(labaPath"table_a.tex", data, "α" => Lr"\alpha_{\text{ср}}")

transform!(data,
    @byRow ((I, α) -> @substitute(H, :I, :α => α)) => :H
)
transform!(data,
    @byRow ((I, α) -> @substitute(thetaH, :I, :α)) => :thetaH
)


namePair = (it) ->
    string(it.name) => LaTeXString(JuliaLaTeX.latexifyDisplayName(it.displayName))


dataToLaTeX(labaPath"table_a2.tex", data, "α" => Lr"\alpha_{\text{ср}}",
    namePair(H),
    namePair(thetaH),
)

@time "datax" table2datax(labaPath"datax.tex", data, "table")

H_l = data[!, :H] .|> JuliaLaTeX.toBaseUnit
thetaH_l = data[!, :thetaH] .|> JuliaLaTeX.toBaseUnit
H_v = sum(H_l) / length(H_l)
thetaH_v = maximum(thetaH_l)

b1 = 8°
b2 = 5°
β = (b1 + b2) / 2
data2 = DataFrame(
    β_1=b1,
    β_2=b2,
    β=β,)


e0_expr = @substitute(e0, :β, :H_v)
theta_e0_expr = @substitute(thetaE, :β, :H_v, :thetaH_v)

transform!(data2,
    @byRow ((β) -> @substitute(e0, :β, :H_v, :thetaH_v)) => :e0
)
transform!(data2,
    @byRow ((β) -> @substitute(thetaE, :β, :H_v, :thetaH_v)) => :thetaE
)


dataToLaTeX(labaPath"table_b.tex", data2, "β" => Lr"\beta_{\text{ср}}",
    namePair(e0),
    namePair(thetaE),
)
table2datax(labaPath"datax.tex", data2, "table", "a")

open(labaPath"datax.tex", "a") do file
    l = [
        ("thetaE", theta_e0_expr, thetaE),
        ("e0", e0_expr, e0),
    ]
    set_default(unitformat=:siunitx, fmt=FancyNumberFormatter(4), env=:raw)
    for (n, expr, f) in l
        JuliaLaTeX.LaTeXDatax.printkeyval(file,
            "calc/$n", expr.displayCalculated
        )
        displayName = JuliaLaTeX.latexifyDisplayName(f.displayName)
        JuliaLaTeX.LaTeXDatax.printkeyval(file,
            "expr/$n", Expr(:(=), LaTeXString(displayName), expr.displayCalculated)
        )
        JuliaLaTeX.LaTeXDatax.printkeyval(file,
            "table[$n]", JuliaLaTeX.UnitSystem.applyUnitTo(expr.inlineWithUnits |> eval, expr.unit)
        )
    end
    for ((name, displayName), v) in [
        (namePair(H), H_v),
        (namePair(thetaH), thetaH_v)
    ]
        JuliaLaTeX.LaTeXDatax.printkeyval(file,
            "table[$(name)]", v
        )
        JuliaLaTeX.LaTeXDatax.printkeyval(file,
            "expr/$(name)", Expr(:(=), displayName, H_v)
        )
    end



    reset_default()
end

# dataToLaTeX("gitignore/test/data_table.tex", data)



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