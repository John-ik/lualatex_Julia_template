using JuliaLaTeX

using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax
using Unitful.DefaultSymbols

using Test
# using TestItems
# using TestItemRunner

# @run_package_tests


@testset "Test substitute near beginning and end" begin
    set_default(env=:raw, fmt=FancyNumberFormatter(4))
    f = :(U)
    str = latexify(f)
    @test str == "U"
    str_subst = JuliaLaTeX.substitute(str, "U" => 10)
    @test str_subst == "10"
    f = latexify(:(U + I))
    @test "10 + I" == JuliaLaTeX.substitute(f, "U" => 10)
    @test "U + 10" == JuliaLaTeX.substitute(f, "I" => 10)
end

@testset "Test on power" begin
    str = latexify(:( U^2 ); env=:raw)
    @test JuliaLaTeX.substitute(str, "U" => 2) == "2^{2}"
    @test JuliaLaTeX.substitute(str, "U" => 2e15) == "(2 \\cdot 10^{15})^{2}"
end