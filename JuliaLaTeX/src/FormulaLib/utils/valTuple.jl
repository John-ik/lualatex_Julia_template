module ValRefModule

export ValRef
__exported__ = [:ValRef]


struct ValRef{x, Value}
    val::Value
    function ValRef{T}(v) where T
        return new{T, typeof(v)}(v)
    end
end
ValRef(x, y) = ValRef{x}(y)
using Base

Base.length(@nospecialize(it::ValRef)) = 1
Base.size(@nospecialize(t::ValRef), d::Integer) = 1
Base.axes(@nospecialize(t::ValRef)) = (OneTo(1),)

Base.firstindex(@nospecialize(it::ValRef)) = 1
Base.lastindex(@nospecialize(it::ValRef)) = 1
Base.getindex(@nospecialize(it::ValRef), i::Int) = getfield(it, i, Base.@_boundscheck)
Base.getindex(@nospecialize(it::ValRef), i::Integer) = getfield(it, convert(Int, i), Base.@_boundscheck)
Base.getindex(@nospecialize(it::ValRef), i::Integer) = getfield(it, convert(Int, i), Base.@_boundscheck)

function Base.iterate(@nospecialize(t::ValRef), i::Int = 1)
    @inline
    return i == 1 ? (t[i], i + 1) : nothing
end

Base.get(t::ValRef, i::Integer, default) = i == 1 ? getindex(t, i) : default
Base.get(f::Base.Callable, t::ValRef, i::Integer) = i == 1 ? getindex(t, i) : f()

end

@safe_using using .ValRefModule

