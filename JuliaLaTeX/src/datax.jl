import LaTeXDatax

store_datax(io::IO, (k, v)::Pair{String,Any}) = LaTeXDatax.printkeyval(io, k, v)
function store_datax(io::IO, d::Vector{Pair{String,Any}})
    for (k, v) in d
        LaTeXDatax.printkeyval(io, k, v)
    end
end