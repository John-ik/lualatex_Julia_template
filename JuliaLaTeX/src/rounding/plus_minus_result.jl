struct PlusMinusResult
    int_value::Int
    int_theta::Int
    tail_size::Int
    e10::Int
    unit::Union{Unitful.Unitlike,Nothing}
end
@save_exported export PlusMinusResult

tail_size(r::PlusMinusResult) = r.tail_size

power_of_ten = @. 10^(0:floor(Int, log10(typemax(Int64))))
print_fraction_with_e10(value::Int, e10::Int) = begin
    b = IOBuffer()
    print_fraction_with_e10(b, value, e10)
    return String(take!(b))
end
print_fraction_with_e10(io::IO, value::Int, e10::Int) = begin
    if e10 == 0
        print(io, value, ".0")
        return
    end
    if e10 <= 0
        print(io, value * 10^(-e10), ".0")
        return
    end

    str_v = string(value)
    l10 = length(str_v)
    d = l10 - e10
    left_part = if d > 0
        print(io, str_v[1:d], '.')
        str_v[d+1:end]
    else
        print(io, "0.", repeat('0', -d))
        str_v
    end
    print(io, left_part[1])
    print(io, rstrip(left_part[2:end], '0'))
end

Base.show(io::IO, r::PlusMinusResult) = begin
    tail_size_ = tail_size(r)
    print(io, '(')
    print_fraction_with_e10(io, r.int_value, tail_size_ - 1)
    print(io, " ± ")
    print_fraction_with_e10(io, r.int_theta, tail_size_ - 1)
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
    power = pm.e10 - pm.tail_size + 1
    t = if power >= 0
        scale = 10^power
        pm.int_value * scale, pm.int_theta * scale
    else
        scale = 10^-power
        pm.int_value / scale, pm.int_theta / scale
    end
    @. UnitSystem.applyUnitTo(float(t), pm.unit)
end