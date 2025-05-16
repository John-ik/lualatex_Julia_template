struct PlusMinusResult
    int_value::Int
    int_theta::Int
    tail_size::Int
    e10::Int
    unit::Union{Unitful.Unitlike, Nothing}
end
@save_exported export PlusMinusResult

tail_size(r::PlusMinusResult) = r.tail_size

dot_position(x::PlusMinusResult) = tail_size(x) - 1
exponent_10(x::PlusMinusResult) = x.e10


Base.show(io::IO, r::PlusMinusResult) = begin
    dot_pos = dot_position(r)
    print(io, '(')
    print_fraction_with_e10(io, r.int_value, dot_pos)
    print(io, " ± ")
    print_fraction_with_e10(io, r.int_theta, dot_pos)
    print(io, ')')
    if r.e10 == 1
        print(io, " * ", 10)
    elseif r.e10 != 0
        print(io, " * ", 10, '^', r.e10)
    end
    if r.unit !== nothing
        print(io, " ", r.unit)
    end
    # print(io, r.int_value÷r10,'.',r.)
end

function Base.float(pm::PlusMinusResult)
    power = pm.e10 - dot_position(pm)
    t = if power >= 0
        scale = 10^power
        pm.int_value * scale, pm.int_theta * scale
    else
        scale = 10^-power
        pm.int_value / scale, pm.int_theta / scale
    end
    @. UnitSystem.applyUnitTo(float(t), pm.unit)
end

function exponent_numbers(pm::PlusMinusResult)
    dot_pos = dot_position(pm)
    value = ExponentNumber{Int}(pm.int_value, dot_pos, pm.e10)
    theta = ExponentNumber{Int}(pm.int_theta, dot_pos, pm.e10)

    return UnitSystem.applyUnitTo(value, pm.unit), UnitSystem.applyUnitTo(theta, pm.unit)
end

function (Base.:*)(pm::PlusMinusResult, unit::Unitful.Unitlike)
    return apply_new_unit(pm, unit)
end
function (Base.:*)(pm::PlusMinusResult, quant::Unitful.Quantity)
    return apply_new_unit(pm, quant)
end
function apply_new_unit(pm::PlusMinusResult, new_unit::Unitful.Quantity)
    value, unit = UnitSystem.extractValueUnitFrom(new_unit)
    exp=if isa(value,ExponentNumber)
        ExponentNumber(value)
    else
        ExponentNumber(value)
    end
    return apply_new_unit(pm,exp,unit)
end
function apply_new_unit(pm::PlusMinusResult, new_unit::Unitful.Unitlike)
    if (pm.unit == new_unit)
        return pm
    end

    local convert_expr_raw = UnitSystem.SI.convertExpr(pm.unit, new_unit)::UnitSystem.SI.ConvertExpr.SimpleConversionExpr
    local convert_info = UnitSystem.SI.ConvertExpr.SimpleConversionExprFields(convert_expr_raw)

    local is_idt = UnitSystem.SI.ConvertExpr.is_identity(convert_expr_raw)
    (is_idt) && (return PlusMinusResult(pm.int_value, pm.int_theta, pm.tail_size, pm.e10, new_unit))

    return apply_new_unit(pm, ExponentNumber(1, 0, convert_info.e10 + pm.e10), new_unit)
end
function apply_new_unit(pm::PlusMinusResult, target_v::ExponentNumber, new_unit::Unitful.Unitlike)

    local convert_expr_raw = UnitSystem.SI.convertExpr(pm.unit, new_unit)::UnitSystem.SI.ConvertExpr.SimpleConversionExpr
    local convert_info = UnitSystem.SI.ConvertExpr.SimpleConversionExprFields(convert_expr_raw)


    local is_idt = UnitSystem.SI.ConvertExpr.is_identity(convert_expr_raw)
    local is_scale = UnitSystem.SI.ConvertExpr.is_scale_only(convert_expr_raw)

    new_e10 = target_v.e10


    mix_factor = convert_info.irr * convert_info.rat
    if mix_factor ≈ 1
        mix_factor = 1
    end

    if abs(target_v.int_value) == 1
        if (is_idt)
            return PlusMinusResult(
                pm.int_value * target_v.int_value,
                pm.int_theta,
                pm.tail_size + (new_e10 - pm.e10),
                new_e10,#pm.e10 + (new_e10 - pm.e10),
                new_unit,
            )
        end

        if is_scale && mix_factor ≈ 1 && target_v.int_value == 1
            local conv_e10 = convert_info.e10
            new_tail = pm.tail_size + (new_e10 - pm.e10)
            if new_unit == pm.unit
                new_tail = new_tail - conv_e10
                return PlusMinusResult(pm.int_value, pm.int_theta, new_tail, new_e10, new_unit)
            else
                new_tail = new_tail - conv_e10
                return PlusMinusResult(pm.int_value, pm.int_theta, new_tail, new_e10, new_unit)
            end
        end
    end
    scale_v = ExponentNumber(target_v.int_value, target_v.dot_position, 0)

    factor = ExponentNumber(mix_factor)
    local (left, right) = exponent_numbers(pm)
    left = (left - convert_info.minus) * factor + convert_info.plus
    right *= factor



    return plus_minus(left * scale_v, right * scale_v; e10 = new_e10)
end