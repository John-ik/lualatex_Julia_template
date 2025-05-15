macro ignore(str) end

@ignore begin
    include("../src/JuliaLaTeX.jl")
    @safe_using using .JuliaLaTeX
end

using JuliaLaTeX

using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax
using Unitful.DefaultSymbols

using Test
# using TestItems
# using TestItemRunner

# @run_package_tests

@testset "rounding" begin
    include("rounding/tests.jl")
end
@testset "formulalib" begin
    include("formulalib/tests.jl")
end
