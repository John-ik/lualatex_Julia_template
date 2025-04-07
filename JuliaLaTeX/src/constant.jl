struct Constant
    text::String
    symbol::String
    quantity::Quantity
    
    Constant(text, symbol, quantity::Quantity) = new(text, symbol, quantity)
    Constant(text, symbol, number::Number)     = new(text, symbol, number * u"one")
    Constant(text, symbol::Symbol)     = new(text, string(symbol),Core.eval( JuliaLaTeX.get_caller_module(2),symbol))
end

constantList = Vector{Constant}([])

Base.show(io::IO, ::MIME"text/latex", c::Constant) = 
    print(io, "$(c.text) \$ $(c.symbol) = $(latexify(c.quantity; env=:raw, unitformat=:siunitx)) \$")


function constantPairs()
    Dict(zip(getproperty.(constantList, :symbol) .|> LaTeXString, getproperty.(constantList, :quantity)))
end
reset_list!(::Type{Constant}) = empty!(constantList)
register!(constants::Constant...) = register!.(constants)

function register!(constant::Constant)
    push!(constantList, constant)
end

constantList_reset!() = empty!(constantList)


function constants2LaTeX()
    io = IOContext(IOBuffer())
    constants2LaTeX(io)
    return String(take!(io.io))
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
            print(io, String(take!(first_io)) |> uppercasefirst)
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



