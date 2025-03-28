#!/bin/env julia

dependencies = [
    "LaTeXStrings"
    "Unitful"
    "UnitfulLatexify"
    "Latexify"
    "LaTeXDatax"
]

using Pkg
Pkg.add(dependencies)

using LaTeXStrings, Unitful, UnitfulLatexify, Latexify, LaTeXDatax
using Unitful.DefaultSymbols

include("greek.jl")