

macro generateBase(expr::Expr)
    map(it::Number) = it
    map(it::Symbol) = it
    map(it::Expr) = map(Val(it.head), it)
    map(::Val{:tuple}, it::Expr) = Expr(:tuple, [map(arg) for arg in it.args]...)
    map(::Val{:call}, it::Expr) = Expr(:call, :simplify, [map(arg) for arg in it.args]...)
    return esc(map(expr))
end


derivative(x::Symbol, f::Symbol) = f == x ? 1 : 0
derivative(x::Symbol, f) = 0
derivative(x::Symbol, f::Expr) = derivative(x, Val(f.head), f)
derivative(x::Symbol, ::Val{:call}, f::Expr) = begin
    derivativeFunction(eval(f.args[1]), x, f.args[2:end]...)
end

derivativeFunction(::typeof(+), x, args...) = simplify(+, [derivative(x, arg) for arg in args]...)
derivativeFunction(::typeof(-), x, a, b) = simplify(-, derivative(x, a), derivative(x, b))

derivativeFunction(::typeof(*), x, oneArg) = derivative(x, oneArg)
derivativeFunction(::typeof(*), x, a, b, args...) = begin
    a_d = derivative(x, a)
    b_d = derivativeFunction(*, x, b, args...)
    @generateBase(a * b_d + b * a_d)
end

derivativeFunction(::typeof(\), x, a, b) = derivativeFunction(/, x, b, a)
derivativeFunction(::typeof(/), x, a, b) = begin
    a_d = derivative(x, a)
    b_d = derivative(x, b)
    # b_d == 0 && return @generateBase(a_d / b)
    # a_d == 0 && return @generateBase(a_d / b)
    @generateBase((b * a_d - a * b_d) / (b^2))
end
derivativeFunction(::typeof(^), x, a, b) = begin
    # @show (:d, ^, a, b)
    a_d = derivative(x, a)
    b_d = derivative(x, b)
    ax = is_depends_on(a, x)
    bx = is_depends_on(b, x)
    # @show (a, a_d, b, b_d)
    !ax && !bx && return 0
    if ax && !bx
        v = :($b * $a^($b - 1) * $a_d)
        # @show v
        return @generateBase(b * a^(b - 1) * a_d)
    end
    if !ax && bx
        # @show :it2
        return @generateBase(log(a) * a^b * b_d)
    end
    # a_d = derivative(x, a)
    # b_d = derivative(x, a)

    # prod=derivativeFunction(*,b,)
    # b * ln(a)
    # b'* ln(a) + b*a'/a
    @generateBase(a^b * (b_d * log(a) + (b * a_d) / a))
end