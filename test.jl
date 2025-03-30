#!/bin/env julia

include("JuliaLaTeX.jl/src/JuliaLaTeX.jl")

U = :(1u"V")
mu_0 = 4pi*1e-7 *u"N/A^2"
U = :($(2+2))
em = :( (8U) / (mu_0^2 * (R_a - R_k)^2 * n_0^2 * I) * I )

str = latexify(em; env=:raw)
