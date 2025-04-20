#= 
function calculation2datax(io::IO, data::DataFrame, calc::Calculation, permissions::String="a")
    set_default(unitformat=:siunitx, fmt=FancyNumberFormatter(4))
    indexes = ["calc/$(calc.to)[$rowi]" for rowi in 1:nrow(data)]
    indexes2 = ["calcfull/$(calc.to)[$rowi]" for rowi in 1:nrow(data)]
    formula = latexify(calc.by; env=:raw)
    data
    formula2 = latexify(inlineConstants(calc.by); env=:raw)
    values = [substitute(formula, merge(constantPairs(), Dict(pairs(data[rowi, :])))...) for rowi in 1:nrow(data)]
    values2 = [substitute(formula2, merge(constantPairs(), Dict(pairs(data[rowi, :])))...) for rowi in 1:nrow(data)]
    LaTeXDatax.datax(io, indexes, values; permissions)
    LaTeXDatax.datax(io, indexes2, values2; permissions)
    reset_default()
end

function calculation2datax(io::IO, data::DataFrame, permissions::String="a")
    (x -> calculation2datax(io, data, x, permissions)).(calculationList)
end

function calculation2datax(data::DataFrame)
    io = IOContext(IOBuffer())
    calculation2datax(io, data)
    return String(take!(io.io))
end
function calculation2datax(filename::String, data::DataFrame, permissions::String="a")
    open(filename, permissions) do io
        calculation2datax(io, data, permissions)
    end
end =#