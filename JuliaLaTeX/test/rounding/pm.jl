let
    make_pm_result(a::Int, b::Int, e10::Int, unit::Union{Nothing, Unitful.Unitlike} = nothing) = begin
        tail_size = JuliaLaTeX.@switch b => {
            _ < 10 => 1;
            _ < 100 => 2;
            _ => 3;
        }
        @assert b ∈ 1:999
        PlusMinusResult(a, b, tail_size, e10, unit)
    end

    @test make_pm_result(106, 2, -1, u"m/s") == 10.6u"m/s" ± 20u"cm/s"
    @test make_pm_result(113, 5, -3, u"m") == 11.3u"cm" ± 5u"mm"

    @test make_pm_result(106, 7, -1, u"m") == 10.627319u"m" ± 2 / 3 * u"m"
    @test make_pm_result(39, 2, 1) == 389.45 ± 21.33
    @test make_pm_result(106, 7, -1) == 10.63 ± 0.7
    @test make_pm_result(1114, 7, -2) == 11.14333 ± 0.07

    @test make_pm_result(622, 12, 1) == 621.54 ± 11.7
    @test make_pm_result(1273, 25, -2) == 1.273 ± 0.023
    @test make_pm_result(432, 9, -2) == 4.316 ± 0.086
    @test make_pm_result(384, 8, -9) == 383.7e-9 ± 8.1e-9

    @test make_pm_result(163, 4, -1) == (16 + 1 / 3) ± 1 / 3
    @test make_pm_result(184, 3, -1) == 18.350 ± 0.287
    @test make_pm_result(334, 3, -1) == 33.450 ± 0.287
    @test make_pm_result(335, 3, -1) == 33.451 ± 0.287



    @test PlusMinusResult(113, 5, 1, 0, u"mm") == (11.3u"cm" ± 5u"mm") * u"mm"
end