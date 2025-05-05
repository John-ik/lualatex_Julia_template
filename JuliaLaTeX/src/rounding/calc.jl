
extract_int_part(value::Number, e10::Int) = begin
    m_l, m = if e10 <= 0
        value * 10^-e10
    else
        value / (10^e10)
    end |> modf
    int_m = floor(Int, m)

    isapprox(m_l, 1) && (int_m += 1; m_l - 1)
    int_m, m_l
end

theta_rounding(x::Number) = begin
    value::Float64, unit = UnitSystem.extractValueUnitFrom(x)

    e10 = floor(Int, log10(abs(value)))

    int_m_100, _ = extract_int_part(value, e10 - 2)
    # @show(int_m_100)
    m1 = int_m_100 ÷ 100
    @assert m1 != 0 LazyString(m1, "!=", 0, "| number = ", x)
    @assert m1 < 10 LazyString(m1, "<", 10, "| number = ", x)
    m2 = (int_m_100 ÷ 10) % 10
    m3 = int_m_100 % 10

    @switch m1 => {
        1 => begin
            m2 += m3 >= 5
            m3 = 0
        end;
        2 => begin
            # @show (m1, m2, m3)
            @switch m2 => {
                _ <= 2 => (m2 = 0);
                #= (3, 4, 5, 6) =#
                _ <= 6 => (m2 = 5);
                _ => begin
                    m1 += 1
                    m2 = 0

                end;
            }
            m3 = 0
        end;
        9 => begin
            e10 += 1
            m1 = 1
            m2 = m3 = 0
        end;
        _ => begin
            m1 += m2 >= 3
            m2 = m3 = 0
        end;
    }

    RoundResult(m1, m2, m3, e10, unit)

end
# theta_rounding = make_rounding(theta_rounding_func)
