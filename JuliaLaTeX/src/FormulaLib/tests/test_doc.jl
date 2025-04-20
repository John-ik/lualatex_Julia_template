include("../init.jl")

macro non(it)

end

@formulas begin
    "R_A DOC"
    const r_a = 15
    const r_b = 15
end
@non(r_a = Formula(r_a))
