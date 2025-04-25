
struct Constant
    formula::Formula
end

processReference(name, v::Constant) = processReference(name, v.formula)

ConstantMaker(args...) = FormulaMaker(Formula(args...))
ConstantMaker(f::Formula) = begin
    c = Constant(f)
    push!(constantList, c)
    return c
end
macro init_constants(expr)
    expand_formulas_macro_with_replacement(__source__, __module__, expr, ConstantMaker)
end

constantList = Vector{Constant}()

Base.show(io::IO, ::MIME"text/latex", c::Constant) = begin
    v = latexify(c.formula.expr.display; env=:raw)
    s = latexifyDisplayName(c.formula.displayName)
    desc = something(description(Main, c.formula), "")
    u = latexify(c.formula.expr.unit; env=:raw)
    print(io, "$desc \$ $s = $v $u\$")
end

reset_list!(::Type{Constant}) = empty!(constantList)


function constants2LaTeX()
    io = IOBuffer()
    constants2LaTeX(io)
    return String(take!(io))
end
function constants2LaTeX(filename::String, permissions::String="w")
    mkpath(dirname(filename))
    open(filename, permissions) do io
        constants2LaTeX(io)
    end
end

function constants2LaTeX(io::IO)
    set_default(unitformat=:siunitx)
    for i in eachindex(constantList)
        if i == 1
            first_io = IOBuffer()
            show(first_io, "text/latex", constantList[i])
            print(io, uppercasefirst(String(take!(first_io))))
        else
            show(io, "text/latex", constantList[i])
        end
        if i != length(constantList)
            print(io, ", ")
        else
            print(io, ".")
        end
    end
    reset_default()
    return
end



