macro remove_line(it...)
    
end

@remove_line include("../../../JuliaLaTeX/src/FormulaLib/utils/init.jl")


include("result_type.jl")
include("calc.jl")
include("plus_minus_result.jl")
include("plus_minus_op.jl")

#= using Requires
@require  =#

include("latexify.jl")