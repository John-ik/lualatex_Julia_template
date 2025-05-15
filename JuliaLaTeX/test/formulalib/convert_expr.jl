




let deg = u"°", rad = NoUnits

    @test :(x * (π / 180)) == JuliaLaTeX.UnitSystem.SI.convertExpr(deg, rad)(:x)
    @test :(x * (180 / π)) == JuliaLaTeX.UnitSystem.SI.convertExpr(rad, deg)(:x)
    @test :(x * 10^-3) == JuliaLaTeX.UnitSystem.SI.convertExpr(u"mm", u"m")(:x)
    @test :(x * 10^-1) == JuliaLaTeX.UnitSystem.SI.convertExpr(u"m", u"mm")(:x)
    @test :(x * 3048 * 10^-1) == JuliaLaTeX.UnitSystem.SI.convertExpr(u"ft", u"mm")(:x)
    @test :(x * 3048 * 10^-4) == JuliaLaTeX.UnitSystem.SI.convertExpr(u"ft", u"m")(:x)
end