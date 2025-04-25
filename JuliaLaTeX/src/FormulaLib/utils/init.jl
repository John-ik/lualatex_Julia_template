macro TODO()
    return error("Not implemented")
end

displayFields(it) = [(fieldnames(typeof(it)) .|> x -> try
    x => getproperty(it, x)
catch e
    "CANNOT GET"
end)...]

writefile(filename::String, v) = begin
    open(filename, "w") do f
        return show(f, "text/plain", v)
    end

    v
end

writefile(filename::String) = v -> writefile(filename, v)


macro __CUR_LINE__()
    return esc(Expr(:quote, __source__))
end

include("importExportedMacro.jl")
include("switch.jl")
include("unionVal.jl")
include("valTuple.jl")
include("generateConstructor.jl")
include("usingMacro.jl")