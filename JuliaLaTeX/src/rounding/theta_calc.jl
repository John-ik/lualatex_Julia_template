
function extract_int_part(value::T, e10::Int) where T
    ten = @switch T => {
        BigInt => BigInt(10),
        UInt128 => UInt128(10),
        Int128 => Int128(10),
        _ <: ExponentNumber => T(T.parameters[1](10)),
        _ => 10,
    }
    m_l, m = if e10 <= 0
        value * ten^-e10
    else
        value / (ten^e10)
    end |> modf
    int_m = floor(Int, m)

    isapprox(m_l, 1) && (int_m += 1; m_l - 1)
    return int_m, m_l
end
function theta_rounding(x::Number)
    unit = UnitSystem.extract_unit(x)
    if (unit !== nothing)
        local r = theta_rounding(UnitSystem.extract_value(x))
        return RoundResult(r.m1, r.m2, r.m3, r.e10, unit)
    end
    value::Float64 = UnitSystem.extract_value(x)
    value = abs(value)
    e10 = floor(Int, log10(value))

    int_m_100, _ = extract_int_part(value, e10 - 2)
    # @show(int_m_100)
    return construct_theta_rounding(x, int_m_100, e10, unit)
end
function theta_rounding(x::ExponentNumber{T}) where T <: Integer
    value = abs(x.int_value)::T
    e10 = floor(Int, log10(value))

    int_m_100, _ = extract_int_part(value, e10 - 2)
    # @show(int_m_100)
    return construct_theta_rounding(x, int_m_100, e10 + real_exponent(x), nothing)
end

function construct_theta_rounding(@nospecialize(original), int_m_100::Int, e10::Int, unit)
    m1 = int_m_100 ÷ 100
    @assert m1 != 0 LazyString(m1, "!=", 0, "| number = ", original)
    @assert m1 < 10 LazyString(m1, "<", 10, "| number = ", original)
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

    return RoundResult(m1, m2, m3, e10, unit)
end

# theta_rounding = make_rounding(theta_rounding_func)
