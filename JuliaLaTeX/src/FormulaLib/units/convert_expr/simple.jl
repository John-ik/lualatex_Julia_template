
struct SimpleConversionExpr{From, To, plus, minus, irr, rat, e10} <: ConversionExpr{From, To}
end
const IdentityConversionExpr{T} = SimpleConversionExpr{T, T, 0, 0, 1, 1, 0}
# const IdentityConversionExpr{T} = IdentityConversionExpr{T<T}

@save_exported export SimpleConversionExpr
@save_exported export IdentityConversionExpr

Base.broadcastable(x::SimpleConversionExpr) = Ref(x)
function Base.fieldnames(::Type{SimpleConversionExpr})
    t = SimpleConversionExpr
    while isa(t, UnionAll)
        t = t.body
    end
    return [it.name for it in t.parameters]
end
function Base.getproperty(x::SimpleConversionExpr, f::Symbol)
    names = fieldnames(SimpleConversionExpr)
    i = 0
    for n in names
        i += 1
        n == f && return typeof(x).parameters[i]
    end
    return getfield(x, f)
end

Base.propertynames(::SimpleConversionExpr) = fieldnames(SimpleConversionExpr)
construct_convert_expr(::From, ::To, t0::Number, t1::Number, irr::Number, rat::Number, e10::Int) where {From, To} =
    construct_convert_expr(From, To, t0, t1, irr, rat, e10)
construct_convert_expr(::Type{From}, ::Type{To}, t0::Number, t1::Number, irr::Number, rat::Number, e10::Int) where {From, To} =
    SimpleConversionExpr{From, To, t0, t1, irr, rat, e10}()

function (expr::ConversionExpr)(x)
    return build_convert_function(expr)(x)

end
function build_convert_function(x::ConversionExpr)
    return raw_build_convert_function(x)
end

function raw_build_convert_function(t0::Number, t1::Number, irr::Number, rat::Number, e10::Number)
    has_number_factor = !(irr == 1 && rat == 1 || irr * rat ≈ 1)
    if !has_number_factor && e10 == 0
        t0 == 0 && t1 == 0 && return identity
        t0 == 0 && return x -> Expr(:call, :+, x, t1)
        t1 == 0 && return x -> Expr(:call, :-, x, t0)
        return x -> Expr(:call, :+, x, -t0, t1)
    end
    ten_in_e10 = (e10 == 1 ? 10 : Expr(:call, :^, 10, e10))
    if !has_number_factor
        factor = ten_in_e10
    elseif e10 == 0
        factor = irr * rat
    else
        factor = Expr(:call, :*, irr * rat, ten_in_e10)
    end
    t0 == 0 && t1 == 0 && return x -> Expr(:call, :*, x, factor)
    t0 == 0 && return x -> Expr(:call, :+, Expr(:call, :*, x, factor), t1)
    t1 == 0 && return x -> Expr(:call, :*, Expr(:call, :-, x, t0), factor)
    return x -> Expr(:call, :+, Expr(:call, :*, Expr(:call, :-, x, t0), factor), t1)
end

@generated function raw_build_convert_function(::SimpleConversionExpr{F, T, 0, 0, 1, 1, 0}) where {F, T}
    return identity
end


@generated function raw_build_convert_function(::SimpleConversionExpr{From, To, t0, t1, irr, rat, e10}) where {From, To, t0, t1, irr, rat, e10}
    return raw_build_convert_function(t0, t1, irr, rat, e10)
end
