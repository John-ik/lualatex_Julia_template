struct Formula
    text::String
    label::String # TODO: special type to check label
    symbol::String
    f::Expr
    dependsOn::Dict{Symbol,Expr}
    Formula(text, symbol::Symbol) = new(text, string(symbol),string(symbol), Core.eval(JuliaLaTeX.get_caller_module(2), symbol),Dict())
    Formula(text, repl::String,symbol::Symbol) = new(text, string(symbol),repl, Core.eval(JuliaLaTeX.get_caller_module(2), symbol),Dict())
    Formula(text, label::String,symbol::String, f::Expr) = new(text, label,symbol,f,Dict())
    Formula(text, symbol::Symbol, f::Expr) = new(text, string(symbol), string(symbol), f,Dict())
end
function dependsOn(f::Formula,other::Union{Pair{Symbol,Expr},Symbol}...)
    local flat(p::Pair{Symbol,Expr})=p
    local flat(symbol::Symbol)=symbol=>Core.eval(JuliaLaTeX.get_caller_module(3), symbol)
    for (k,v) in [flat.(other)...]
        f.dependsOn[k]=v
    end
    return f
end

module NoneModule end
@latexrecipe function f(formula::Formula; label::String="")
    # TODO: using label type

    env --> :eq
    # return quote $label $(formula.symbol) = $(formula.f) end
    f=first(JuliaLaTeX.inlineConstAndVars(formula.f,formula.dependsOn;m=NoneModule))
    expr = quote
        $(formula.symbol) = $(f)
    end
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

reset_list!(::Type{Formula}) = empty!(formulaList)
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
        println(io, "\\par")
    end
    reset_default()
    return
end