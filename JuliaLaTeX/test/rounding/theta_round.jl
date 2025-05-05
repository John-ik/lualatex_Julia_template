let make_r_result(m123::Int, e10::Int, unit::Union{Nothing,Unitful.Unitlike}=nothing) = begin
        @assert 0 < m123 < 1000 "m123 must be in range [1,999]"
        JuliaLaTeX.@switch m123 => {
            _ < 10 => begin
                RoundResult(m123 % 10, 0, 0, e10, unit)
            end;
            _ < 100 => begin
                RoundResult((m123 ÷ 10) % 10, m123 % 10, 0, e10, unit)
            end;
            _ => begin
                RoundResult(m123 ÷ 100, (m123 ÷ 10) % 10, m123 % 10, e10, unit)
            end;
        }
    end



    @test make_r_result(120, 1, u"m") == theta_rounding(11.7u"m")
    @test make_r_result(7, -1, u"m") == theta_rounding(2 / 3 * u"m")
    @test make_r_result(2, 1) == theta_rounding(21.33)
    @test make_r_result(25, -2) == theta_rounding(0.023)
    @test make_r_result(2, -2) == theta_rounding(0.022)
    @test make_r_result(4, -1) == theta_rounding(1 / 3)
    @test make_r_result(9, -2) == theta_rounding(0.086)
    @test make_r_result(3, -1) == theta_rounding(0.287)

end