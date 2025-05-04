include("evaluatable.jl")
include("formula.jl")


Base.broadcastable(x::Formula)=Ref(x)
Base.broadcastable(x::Evaluatable)=Ref(x)