using Unitful
include("../init.jl")

macro ignore(it)
    return it
end
@formulas begin
    const r_a = 15u"mm"
    const r_k = 7u"mm"
    const theta_R = 1u"mm"
    # R0 = (:r_a - :r_k) / 2

    R = ($r_a - $r_k) / 2
    @ignore Core.eval(@__MODULE__, R.expr.inlineWithUnits) |> setCalculated(R.expr)

    test1 = m / ($R^2)
    test2 = m*$:test1

end

;