

macro u_str(str)
    # dump(str)
    im
end

# em = (e / m) = 7*10u"m/s"
# em = (:(e / m), :(R * 2))
@formulas begin

    θ_R = 3 * 10^7 * u"haha UNit"

    em = (e / m) = 7 * 10 * u"m/s"

    θ_em = (θ_(e / m)) = :em * (:θ_R / R) * u"m/s"


end
θ_em


# # formula = makeFormula(:(θ_ = :em * (θ_r/R)))

# println(string(formula[1], " = ", formula[2]));

# println("calc#1 inlineResolved ", string(inlineResolved(formula[2], :name)))
# println("todo calc#1 inlineResolved ");
# println();

# println("display inlineResolved ", string(inlineResolved(formula[2], :value)));
# println();