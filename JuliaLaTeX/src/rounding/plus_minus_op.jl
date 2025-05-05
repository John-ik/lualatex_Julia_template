NothingOr{X} = Union{Nothing,X}


function plus_minus(a::Number, b::RoundResult; e10::Int=b.e10, unit::Unitful.Unitlike)
    plus_minus(a, float(a); e10, unit)
end
function plus_minus(value::Number, round::RoundResult; e10::Int=round.e10)
    value::Number = UnitSystem.extractValue(UnitSystem.applyUnitTo(value, round.unit))
    tail_s=tail_size(round)
    e10_1 = round.e10 - tail_s + 1
    int_part_100, off_part = extract_int_part(value, e10_1 - 2)
    int_part = int_part_100 ÷ 100
    part_100 = int_part_100 % 100
    @switch part_100 => {
        _ < 50 => ();
        _ > 50 => begin
            int_part += 1
        end;
        _ == 50 => begin
            if off_part ≈ 0
                int_part += int_part & 1
            else
                error("I dont know how to round it value='", value, "', round='", round, "', e10=", e10)
            end
        end;
        _ => error("Unknown situation");
    }
    PlusMinusResult(int_part, int_head(round)÷(10^(3-tail_s)), tail_s+(e10-round.e10), e10, round.unit)
end

plus_minus(a::Number, b::Number, unit::Unitful.Unitlike, e10::NothingOr{Int}=nothing) = begin
    t = (a, b)
    a, b = @. UnitSystem.applyUnitTo(t, unit)
    b = theta_rounding(b)
    plus_minus(a, b; e10=(e10 === nothing ? b.e10 : e10))
end
plus_minus(a::Number, b::Number; e10::NothingOr{Int}=nothing) = begin
    unit = Unitful.promote_unit(Unitful.unit(a), Unitful.unit(b))
    plus_minus(a, b, unit, e10)
end
plus_minus(a::Number) = Base.Fix1(plus_minus, a)
plus_minus(b::RoundResult) = Base.Fix2(plus_minus, b)

± = plus_minus


@save_exported export ±, plus_minus