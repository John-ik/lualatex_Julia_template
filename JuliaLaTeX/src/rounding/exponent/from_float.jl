

const STD_FLOAT = Union{Float16, Float32, Float64}
function split_sign_exp_sig_bits(x::STD_FLOAT)
    local m1 = reinterpret(UInt64, (-1))
    local exp_bits = x |> typeof |> Base.exponent_bits
    local size_ = sizeof(x) * 8
    local signifi_bits = size_ - exp_bits - 1
    local diff = 64 - size_
    local s = reinterpret(UInt64, x) >>> diff
    # @show bitstring(~(m1 << signifi_bits))
    local significant_part = (~(m1 << signifi_bits)) & s
    local exp_part = (~(m1 << exp_bits)) & (s >>> signifi_bits)
    # @show bitstring((s >>> signifi_bits))
    # @show bitstring(~(m1 << exp_bits))
    local sign = x < 0 ? 1 : 0
    return (sign, Int64(exp_part) - (1 << (exp_bits - 1) - 1), Int64(significant_part), signifi_bits)
end

const big5 = BigInt(5);
const uns5 = UInt64(5);
bitstr(x) = string(x; base = 2);

function transform_e10_line(x::STD_FLOAT)
    local (sign, exp, sig_original, sig_original_bits) = split_sign_exp_sig_bits(x)
    # sig_original += 2 << sig_original_bits
    local sig = sig_original
    local counter = 0
    sig += 1 << sig_original_bits
    local sig_bits = sig_original_bits

    while (sig & 1) == 0 && sig > 0
        sig >>>= 1
        counter += 1
    end
    sig_bits -= counter
    value = reinterpret(UInt64, sig)

    e2 = exp - sig_bits
    # x = sig_2 * (10)_2^n
    # x = sig * 2^n
    if e2 >= 0
        e10 = 0
        while e2 > 0 && (value % 5) == 0
            value ÷= 5
            e2 -= 1
            e10 += 1
        end
        if e10 > 0
            sig_bits = 64 - leading_zeros(value) - 1
        end
        local max_bits = (sig_bits + 1) + e2# len + length(bin(5))*len = len + 3*len = 4*len

        if max_bits <= 64
            value <<= e2
        else
            value = BigInt(value) << e2
        end
    else
        # x = sig * 2^n; k=-n
        # x = sig / 2^k
        # x = sig / (2^k*5^k) * (5^k)
        # x = sig * 5^k / 10^k
        # x = sig * 5^k * 10^n
        e10 = e2
        local max_bits = (sig_bits + 1) - 3 * e2# len + length(bin(5))*len = len + 3*len = 4*len
        if max_bits <= 64
            value *= uns5^-e2
        else
            value *= big5^-e2
        end
    end
    return (sign, BigInt(value), e10)
end

count_limbs(x::BigFloat) = (x.prec + 8 * Core.sizeof(Base.GMP.Limb) - 1) ÷ (8 * Core.sizeof(Base.GMP.Limb))

function split_sign_exp_sig_bits(x::BigFloat)
    (x == 0) && return (0, 0, 0, -1)
    local sig_part = nothing
    local limbs = count_limbs(x)
    local bitlenght = 0
    for i in 1:limbs
        local n = unsafe_load(x.d, i)
        n == 0 && continue
        local offset = limbs - i

        if sig_part === nothing
            n = (n << 1) >>> 1
            n == 0 && continue
            bitlenght = (BigInt(offset + 1) << 6) - 1
            if offset == 0
                sig_part = n
            else
                sig_part = BigInt(n) << (offset << 6)
            end
        else
            sig_part |= BigInt(n) << (offset << 6)
        end
    end
    if sig_part === nothing
        return (0, 0, 0, 0)
    end
    return (signbit(x) * 1, x.exp - 1, sig_part, bitlenght)

end
function transform_e10_line(x::BigFloat)
    local (sign, exp, sig_original, sig_original_bits) = split_sign_exp_sig_bits(x)
    # sig_original += 2 << sig_original_bits
    local sig = sig_original
    local counter = typeof(sig_original)(0)
    sig += BigInt(1) << sig_original_bits
    local sig_bits = sig_original_bits
    while (sig & 1) == 0 && sig > 0
        sig >>>= 1
        counter += 1
    end
    sig_bits -= counter
    value = BigInt(sig)
    e2 = exp - sig_bits
    # x = sig_2 * (10)_2^n
    # x = sig * 2^n
    if e2 >= 0
        e10 = 0
        while e2 > 0 && (value % 5) == 0
            value ÷= 5
            e2 -= 1
            e10 += 1
        end
        value <<= e2
    else
        e10 = e2
        value *= big5^-e2
    end
    return (sign, value, e10)
end



function Base.promote_rule(::Type{ExponentNumber{A}}, ::Type{T}) where {A <: Integer, T <: Union{Float16, Float32, Float64, BigFloat}}
    return ExponentNumber
end#= 
function ExponentNumber{A}(n::Union{Float16, Float32, Float64, BigFloat}) where A<:Integer
    return ExponentNumber{A}(ExponentNumber(n))
end =#
function ExponentNumber(n::Union{Float16, Float32, Float64, BigFloat})
    local (sign, int, e10) = transform_e10_line(n)
    if isa(int, BigInt)
        if int.size <= 1
            local uint = UInt64(int)
            if (uint >> 63) == 0
                int = reinterpret(Int64, uint | sign<<63)
            end
        elseif sign == 1
            int = -int
        end
    elseif sign == 1
        int = -int
    end
    return ExponentNumber(int, Int(-e10), 0)
end