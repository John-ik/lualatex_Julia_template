include("../FormulaLib/utils/init.jl")

ensure_iterable(x) = applicable(iterate, x) ? x : [x]