include("each_name.jl")
include("calc_macro.jl")
include("calc_type.jl")

@save_exported export @with_name

macro with_name(name::Union{String,Symbol}, stmt::Expr)
    @assert Meta.isexpr(stmt, :(=)) "Allowed only 'SOME = VALUE|EXPR'"
    esc(Expr(:(=), Expr(:ref, self_calculation_name, QuoteNode(Symbol(name))), stmt))
end

