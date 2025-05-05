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

@testset "Test on power" begin
    str = latexify(:( U^2 ); env=:raw)
    @test JuliaLaTeX.substitute(str, "U" => 2) == "2^{2}"
    @test JuliaLaTeX.substitute(str, "U" => 2e15) == "(2 \\cdot 10^{15})^{2}"
end
