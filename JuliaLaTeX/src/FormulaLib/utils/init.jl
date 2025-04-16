macro TODO()
    error("Not implemented")
end

displayFields(it) = [(fieldnames(typeof(it)) .|> x -> try
    x => getproperty(it, x)
catch e
    "CANNOT GET"
end)...]

 writefile(filename::String,v)=begin
    open(filename,"w") do f
        show(f,"text/plain",v)
    end

    v
 end

 writefile(filename::String)=v->writefile(filename,v)

include("unionVal.jl")
include("valTuple.jl")
include("generateConstructor.jl")