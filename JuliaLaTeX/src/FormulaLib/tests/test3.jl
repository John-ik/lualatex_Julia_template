using Unitful

include("../init.jl")

macro ignore(it)
    return it
end

@formulas begin
    "радиус анода"
    r_a = 15u"mm"    #= const =#
    "радиус катода"
    r_k = 7u"mm"    #= const =#
    "число витков на единицу длины"
    n_0 = 1800u"1/m"    #= const =#
    "магнитная постоянная"
    μ_0 = (4 * π * (10^(-7))) * u"H/m"    #= const =#
    "Систематическая погрешность вольтметра"
    theta_U = 0.375u"V"    #= const =#
    "Систематическая погрешность амперметра"
    theta_I = 0.01u"A"    #= const =#
    "Систематическая погрешность длины"
    theta_R = 1u"mm"    #= const =#


    "Радиус кривизны траектории электрона"
    R = (r_a - r_k) / 2    #= const =#
    @ignore begin
        R.expr.inlineWithUnits |> eval |> setCalculated(R.expr)
    end

    "Удельный заряд электрона"
    em = e / m = (2 * $U) / (μ_0^2 * R^2 * n_0^2 * $I_c^2)    #= const =#
    # em = e / m = (2 * $U) / (μ_0^2 * R^2 * n_0^2 * $I_c^2)    #= const =#
    "Систематической погрешность удельный заряд электрона"
    thetaem = θ_{:em} = em * (theta_U / $U + (2theta_I) / $I_c + (2theta_R) / R)    #= const =#
    # thetaem = θ_{:em} = em * (theta_U / $U + (2theta_I) / $I_c + (2theta_R) / R)    #= const =#

end
dataToCalc = [
    (0.9u"A", 10u"V"),
    (0.96u"A", 14u"V"),
]

for (I_c, U) in dataToCalc
    eval(:(I_c = $I_c; U = $U))
    v = @substitute(em, :I_c, :U)
    @show (I_c, U, v.displayCalculated)
end