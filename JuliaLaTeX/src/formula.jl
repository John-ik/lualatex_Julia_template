struct Formula
    text::String
    label::String # TODO: special type to check label
    symbol::String
    f::Expr
end

@latexrecipe function f(formula::Formula; label::String="")
    # TODO: using label type

    env --> :eq
    # return quote $label $(formula.symbol) = $(formula.f) end
    expr = quote $(formula.symbol) = $(formula.f) end
    if label == ""
        return Expr(:latexifymerge, expr)
    else
        return Expr(:latexifymerge, expr, "\\label{formula:$label}")
    end
end

function Base.show(io::IO, ::MIME"text/latex", formula::Formula)
    # iscompact = get(io, :compact, false)::Bool # check if compact provided
    print(io, "$(formula.text): $(latexify(formula))")
end

formulaList = Vector{Formula}([])

register!(formulas::Formula...) = register!.(formulas)

function register!(formula::Formula)
    push!(formulaList, formula)
end

formulaList_reset!() = empty!(formulaList)



function formulas2LaTeX()
    io = IOContext(IOBuffer())
    formulas2LaTeX(io)
    return String(take!(io.io))
end
function formulas2LaTeX(filename::String, permissions::String="w")
    open(filename, permissions) do io
        formulas2LaTeX(io)
    end
end
function formulas2LaTeX(io::IO)
    set_default(unitformat=:siunitx)
    for i in eachindex(formulaList)
        formula = formulaList[i]
        set_default(label=formula.label)
        show(io, "text/latex", formula)
        print(io, "")
    end
    reset_default()
    return 
end