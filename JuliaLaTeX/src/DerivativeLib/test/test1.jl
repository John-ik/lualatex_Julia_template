@time include("../init.jl")




f = :(10x * (x + 2) * x)
f2 = :((10x * x + 20x) * x)
f3 = :(10x * x * x + 20x * x)

F = :((2 * U) / (μ_0^2 * R^2 * n_0^2 * I_c^2))
# dx=Differential(:x)
# dx(f)

println(derivative(:x, :(5x + x)))
derivative(:x, :(1 / (x * x)))
println()


function theta_F(f)
    vars = Set{Symbol}()

    collectVars(it::Symbol) = push!(vars, it)
    collectVars(it::Union{QuoteNode, Number}) = nothing
    collectVars(it::Expr) = collectVars(Val(it.head), it.args)
    collectVars(::Val{:call}, args::Vector) = begin
        for it in args[2:end]
            collectVars(it)
        end
    end
    sum = Expr(:call, :+)
    log_version = transform_to_log(f)
    collectVars(f)
    for v in vars
        # d = derivative(v, log_version)
        d = simplify(Expr(:call, :*,
            Symbol("theta_$v"),
            derivative(v, log_version),
        ))
        # @show  
        Meta.isexpr(d, :call) && d.args[1] == :- && length(d.args) == 2 && (d = d.args[2])
        push!(sum.args, d)
    end


    return sum
end
println()
r_a=15
r_k=7
theta_r_a=theta_r_k=1

# difV(:x, hmmm)
# difV(:y, hmmm)
# difV(:z, hmmm)
# difV(:w, hmmm)
@time println(Expr(:call, :*, F, theta_F(F)))
println()