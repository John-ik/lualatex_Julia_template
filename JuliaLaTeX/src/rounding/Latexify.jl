@assert @isdefined(Latexify) "run 'using Latexify' before this script"

using Latexify

@latexrecipe function f(pm::PlusMinusResult)
    operation := pm.unit === nothing ? :* : :none

    tail_s = tail_size(pm)
    value = print_fraction_with_e10(pm.int_value, tail_s - 1)
    theta = print_fraction_with_e10(pm.int_theta, tail_s - 1)
    pm_expr = Expr(:call, :±, value, theta)
    if pm.e10 != 0
        pm_expr = Expr(:call, :*, pm_expr,
            if pm.e10 == 1
                10
            else
                Expr(:call, :^, 10, pm.e10)
            end
        )
    end
    if pm.unit === nothing
        return pm_expr
        # env --> :raw
    else
        return Latexify.LaTeXString(string("\\left(", latexify(pm_expr;kwargs...),"\\right)", latexify(pm.unit;kwargs...)))
    end
end