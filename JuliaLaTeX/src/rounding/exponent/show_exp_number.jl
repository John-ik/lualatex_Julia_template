
power_of_ten = @. 10^(0:floor(Int, log10(typemax(Int64))))

print_fraction_with_e10(value::Integer, e10::Int) = begin
    b = IOBuffer()
    print_fraction_with_e10(b, value, e10)
    return String(take!(b))
end

print_fraction_with_e10(io::IO, value::Integer, e10::Int) = begin
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


function Base.show(io::IO, exp::ExponentNumber)
    print_fraction_with_e10(io, exp.int_value, exp.dot_position)
    (exp.e10 == 0) && (return)
    if exp.e10 == 1
        print(io, " * ", 10)
    else
        print(io, " * ", 10, "^", exp.e10)
    end

end