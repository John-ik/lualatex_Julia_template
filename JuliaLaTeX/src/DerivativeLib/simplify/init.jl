

simplify_can_eval(any) = false
for f in [-, +, /, \, ^, *]
    fType = typeof(f)
    Core.eval(@__MODULE__, :(simplify_can_eval(::$fType) = true))
end

simplify(f::Symbol) = f
simplify(f::Number) = f
simplify(f::Expr) = simplify(Val(f.head), f.args)
simplify(::Val{:call}, args) = begin
    # @show (:call, args)
    fType = eval(args[1])
    newArgs = (args[2:end] .|> simplify)
    if simplify_can_eval(fType)
        t = tuple(newArgs...)
        # @show (t, typeof(t))
        length(methods(fType, typeof(t))) > 0 && try
            return fType(newArgs...)
        catch
        end
    end
    simplify(fType, newArgs...)
end

simplify(::typeof(-), a) = begin
    typeof(a) <: Number && return -a
    if Meta.isexpr(a, :call)
        @switch a.args[1] => {
            :- => begin
                if length(a.args) == 2
                    return a.args[2]
                else
                    return simplify(-, a.args[3], a.args[2])
                end
            end,
        }

    end
    Expr(:call, :-, a)
end
simplify(::typeof(-), a, b) = begin
    # @show (:-, 2, a, b)
    a == 0 && return simplify(Val{:call}(), [:-, b])
    b == 0 && return a
    Expr(:call, :-, a, b)
end
simplify(::typeof(+), args...) = begin
    newArgs = nothing
    sum = nothing
    for a in args
        a == 0 && continue
        if isa(a, Number)
            sum === nothing ? (sum = a) : (sum += a)
        else
            newArgs === nothing && (newArgs = [])
            push!(newArgs, a)
        end
    end
    newArgs === nothing && sum === nothing && return 0
    newArgs === nothing && return sum
    sum !== nothing && push!(newArgs, sum)
    @switch length(newArgs) => {
        0 => 0,
        1 => newArgs[1],
        _ => Expr(:call, :+, newArgs...),
    }
end
@generated function multipleSort(x, y)
    x != y && return :(isless(string($x.name), string($y.name)))
    return :(isless(x, y))
end
Base.isless(x::Expr, y::Expr) = isless(x.head, y.head) || x.head == y.head && multipleSort(x.args, y.args)

simplify(::typeof(*), args...) = begin
    newArgs = nothing
    prod = nothing
    denom = nothing
    sign = false
    for a in args
        if Meta.isexpr(a, :call)
            @switch a.args[1] => {
                :/ => begin
                    denom === nothing && (denom = [])
                    push!(denom, a.args[3])
                    a = a.args[2]
                end,
                :\ => begin
                    denom === nothing && (denom = [])
                    push!(denom, a.args[2])
                    a = a.args[3]
                end,
                :- => begin
                    if length(a.args) == 2
                        sign = !sign
                        a = a.args[2]
                    end

                end,
            }
        end
        a == 0 && return 0
        a == 1 && continue
        if isa(a, Number)
            if a < 0
                sign = !sign
                a = -a
            end
            prod === nothing ? (prod = a) : (prod *= a)
        else
            newArgs === nothing && (newArgs = [])
            (push!(newArgs, a))
        end
    end
    newArgs === nothing && prod === nothing && return 1

    prod = newArgs === nothing ? prod : begin
        # prod !== nothing && insert!(newArgs, 1, prod)
        @switch (length(newArgs) + (prod !== nothing)) => {
            0 => 1,
            1 => newArgs[1],
            _ => prod !== nothing ? Expr(:call, :*, prod, newArgs...) : Expr(:call, :*, newArgs...),
        }
    end
    prod = denom === nothing ? prod : simplify(/, prod, simplify(*, denom...))
    sign && (prod = simplify(-, prod))
    return prod
end
simplify(::typeof(\), a, b) = simplify(/, b, a)
extractDivision(a) = !Meta.isexpr(a, :call) ? nothing : begin
    @switch a.args[1] => {
        :/ => (a.args[2], a.args[3]),
        :\ => (a.args[3], a.args[2]),
        _ => nothing;
    }
end
extractMultiply(a) = begin
    list = Meta.isexpr(a, :call) && a.args[1] == :* ? a.args[2:end] : [a]
    Dict([x => count(==(x), list) for x in unique(list)]...)
end
dictToProduct(d) = simplify(*, [simplify(^, k, v) for (k, v) in d]...)
simplify(::typeof(/), a, b) = begin
    ext = extractDivision(a)
    # @show (a, b, ext)
    if ext !== nothing
        a = ext[1]
        b = simplify(*, b, ext[2])
    end
    ext = extractDivision(b)
    # @show (a, b, ext, 2)
    if ext !== nothing
        a = simplify(*, a, ext[2])
        b = ext[1]
    end
    # @show (a, b)

    if true
        a_dict = extractMultiply(a)
        b_dict = extractMultiply(b)
        merge_dict = Dict([x => min(get(b_dict, x, 0), v) for (x, v) in a_dict]...)
        for (k, delta) in merge_dict
            haskey(a_dict, k) && (a_dict[k] -= delta)
            haskey(b_dict, k) && (b_dict[k] -= delta)
        end

        a = dictToProduct(a_dict)
        b = dictToProduct(b_dict)
        # @show a, b
    end

    b == 1 && return a
    b == 0 && return NaN
    a == 0 && return 0
    a == b && return 1

    Expr(:call, :/, a, b)
end
simplify(::typeof(^), a, b) = begin
    b == 0 && return 1
    b == 1 && return a
    Expr(:call, :^, a, b)
end