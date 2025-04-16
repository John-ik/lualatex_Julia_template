include("../init.jl")
using Unitful
# macro u_str(str)
#     # dump(str)
#     im
# end

macro ignore(it)
    return it
end
UnitSystem.SI.preferredUnit(::typeof(dimension(u"C/kg")))=u"C/kg"
@formulas begin
    const r_a = 15u"mm"
    const r_k = 7u"mm"
    const n_0 = 1800u"1/m"
    # Space is important, just for now, to separate expression and unit
    const μ_0 = (4π * (10^(-7))) * u"H/m"

    const theta_U = 0.375u"V"
    const theta_I = 0.01u"A"
    const theta_R = 1u"mm"
    # R0 = (:r_a - :r_k) / 2

    R = ($r_a - $r_k) / 2
    @ignore Core.eval(@__MODULE__, R.expr.inlineWithUnits) |> setCalculated(R.expr)

    em = e / m = (2 * U) / ($μ_0^2 * $R^2 * $n_0^2 * I_c^2)

    test_em = test_{:em} = m / ($R^2)


    θ_em = θ_{:em} = $:em * ($theta_U / U + (2 * $theta_I) / I_c + (2 * $theta_R) / $R)

end

dataToCalc = [
    (0.9u"A", 10u"V"),
    (0.96u"A", 14u"V"),
]

for (I_c, U) in dataToCalc
    eval(:(I_c = $I_c; U = $U))
    @substitute(em, :I_c, :U)
end