using JuliaLaTeX

using TestItems
using TestItemRunner

@run_package_tests


@testitem "Test substitute near beginning and end" begin
    em = :(U)
    str = latexify(em; env=:raw)
end