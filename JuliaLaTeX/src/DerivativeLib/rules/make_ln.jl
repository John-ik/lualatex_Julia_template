


function derivative_ln(x::Symbol, f)
    return derivative(x, transform_to_log(f))
end
transform_to_log(f::Symbol) = Expr(:call, :log, f)
transform_to_log(f::Expr) = transform_to_log(Val(f.head), f)
transform_to_log(f::Number) = Expr(:call, :log, f)
transform_to_log(::Val{:call}, f::Expr) = transform_to_log_func(Val(f.args[1]), f.args[2:end]...)
transform_to_log_func(it::Val, args...) = Expr(:call, :log, Expr(:call, typeof(it).parameters[1], args...))
transform_to_log_func(::Val{:*}, args...) = simplify(+, (args .|> transform_to_log)...)
transform_to_log_func(::@unionVal(:exp, :expm1), a) = a
transform_to_log_func(::Val{:exp2}, a) = @generateBase(a * log(2))
transform_to_log_func(::Val{:exp10}, a) = @generateBase(a * log(10))
transform_to_log_func(::Val{:sqrt}, a) = @generateBase(1 / 2 * log(a))
transform_to_log_func(::Val{:^}, a, b) = begin
    inner = transform_to_log(a)
    @generateBase(b * inner)
end
transform_to_log_func(::Val{:\}, a, b) = transform_to_log_func(Val{:/}, b, a)
transform_to_log_func(::Val{:/}, a, b) = begin
    a = transform_to_log(a)
    b = transform_to_log(b)
    @generateBase(a - b)
end