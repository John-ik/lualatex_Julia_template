
struct Calculation
    dict::Dict{Symbol,Any}
    order::Vector{Symbol}
end
@save_exported export Calculation

Calculation() = Calculation(Dict{Symbol,Any}(), Vector())



Base.length(it::Calculation) = length(it.order)
Base.size(it::Calculation, d::Integer) = size(it.order, d)
Base.axes(it::Calculation) = axes(it.order)

Base.firstindex(it::Calculation) = 1
Base.lastindex(it::Calculation) = Base.lastindex(it.order)

Base.getindex(it::Calculation, i::Integer) = it.order[i] => it.dict[it.order[i]]
Base.getindex(it::Calculation, i::Symbol) = it.dict[i]
Base.getindex(it::Calculation,::typeof(!), i::Integer) = map(x->it.dict[x][i],it.order)


Base.setindex!(it::Calculation, value, i::Symbol) = begin
    if !haskey(it.dict, i)
        push!(it.order, i)
    end
    it.dict[i] = value
    value
end

function Base.iterate(t::Calculation, i::Int=1)
    @inline
    return i <= length(t) ? (t[i], i + 1) : nothing
end

Base.get(t::Calculation, i::Integer, default) = i == 1 ? getindex(t, i) : default
Base.get(f::Base.Callable, t::Calculation, i::Integer) = i == 1 ? getindex(t, i) : f()
Base.getproperty(x::Calculation, f::Symbol) = begin
    d = getfield(x, :dict)
    haskey(d, f) ? d[f] : (@inline; getfield(x, f))
end

Base.propertynames(t::Calculation) = [keys(t.dict)..., fieldnames(typeof(t))...]