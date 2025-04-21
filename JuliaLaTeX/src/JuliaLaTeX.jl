Core.eval(Main, :(wasJuliaLatex = false))
Main.wasJuliaLatex = @isdefined JuliaLaTeX
module JuliaLaTeX

include("init.jl")

end