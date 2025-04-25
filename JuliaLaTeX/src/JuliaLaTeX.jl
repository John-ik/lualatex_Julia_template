
Core.eval(Main, :(wasJuliaLatex = false))
Main.wasJuliaLatex = @isdefined JuliaLaTeX
module JuliaLaTeX

macro namedTime(stmt::Expr)
    esc(stmt)
    # esc(Expr(:macrocall, Symbol("@time"), __source__, string(stmt), stmt))
# esc(stmt)
    # esc(Expr(:block,
    #     Expr(:macrocall, Expr(:., :Profile, Symbol("@profile")), __source__, stmt),
    #     Base.remove_linenums!(:(Profile.print()))
    # ))
end


@time "main init" include("init.jl")

end