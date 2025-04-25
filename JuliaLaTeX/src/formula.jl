
# module FormulaLib

include("FormulaLib/init.jl")
# end
# Formula = FormulaLib.Formula
# @usingMacro using .FormulaLib


function expand_formulas_macro_with_replacement(__source__::LineNumberNode, __module__::Module, expr, newConstructor)
    expr = var"@formulas"(__source__, __module__, expr)
    replaceMaker(it) = it
    replaceMaker(it::Expr) = replaceMaker(Val(it.head), it)
    replaceMaker(::Val, it::Expr) = Expr(it.head, map(replaceMaker,it.args)...)
    replaceMaker(::Val{:call}, it::Expr) = begin
        it.args[1] == :Formula ? Expr(:call, newConstructor, it) : expr
    end
    return replaceMaker(expr)
end

function FormulaMaker(f::Formula)
    push!(formulaList, f)
    f.displayName = Symbol(latexifyDisplayName(f.displayName))
    return f
end

macro init_formulas(expr)
    expand_formulas_macro_with_replacement(__source__, __module__, expr, FormulaMaker)
end

transformChar(c::Char) = c == '_' ? c : get(Latexify.unicodedict, c,c)
filterName(s) = join(map(transformChar,collect(s)))

latexifyDisplayName(expr::Symbol) = filterName(string(expr))
latexifyDisplayName(expr::Number) = latexify(expr)
latexifyDisplayName(expr::String) = expr
latexifyDisplayName(expr::Expr) = @switch expr.head => {
    :curly => begin
        it = string(latexifyDisplayName(expr.args[1]), '{', latexifyDisplayName(expr.args[2]), '}')
        # @show it
        it
    end,
    :call => begin
        it = string(latexify(Expr(:call, expr.args[1], map(latexifyDisplayName,expr.args[2:end])...); env = :raw))
        it
    end,
    Symbol("'") => begin
        it = string("{", latexifyDisplayName(expr.args[1]), "}'")
        # @show it
        it
    end,
    _ => error("Unsupported displayName expr type '$(expr.head)' -> \"$(expr)\"");
}

@latexrecipe function f(formula::Formula; label::String="")
    # TODO: using label type



    env --> :eq
    # return quote $label $(formula.symbol) = $(formula.f) end
    f = formula.expr.display

    displayName = latexifyDisplayName(formula.displayName)
    # @show (formula.displayName => displayName)
    expr = Expr(:(=), displayName, f)
    if label == ""
        return Expr(:latexifymerge, expr)
    else
        return Expr(:latexifymerge, expr, "\\label{formula:$label}")
    end
end

function Base.show(io::IO, ::MIME"text/latex", formula::Formula)
    # iscompact = get(io, :compact, false)::Bool # check if compact provided
    desc = description(Main, formula)
    print(io, "$(desc): $(latexify(formula))")
end

formulaList = Vector{Formula}([])

reset_list!(::Type{Formula}) = empty!(formulaList)


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
        set_default(label=formula.name)
        show(io, "text/latex", formula)
        println(io, "\\par")
    end
    reset_default()
    return
end