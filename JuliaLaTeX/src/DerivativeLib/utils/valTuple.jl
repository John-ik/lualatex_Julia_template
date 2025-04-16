

struct ValRef{x, Value}
    val::Value
    function ValRef{T}(v) where T
        new{T,typeof(v)}(v)
    end
end
ValRef(x, y) = ValRef{x}(y)



Core.eval(Base, quote
    # Val(it::$ValRef) = Val(typeof(it).parameters[1])

    length(@nospecialize(it::$ValRef)) = 1
    size(@nospecialize(t::$ValRef), d::Integer) = 1
    axes(@nospecialize(t::$ValRef)) = (OneTo(1),)

    firstindex(@nospecialize(it::$ValRef)) = 1
    lastindex(@nospecialize(it::$ValRef)) = 1
    getindex(@nospecialize(it::$ValRef), i::Int) = getfield(it, i, Base.@_boundscheck)
    getindex(@nospecialize(it::$ValRef), i::Integer) = getfield(it, convert(Int, i), Base.@_boundscheck)
    getindex(@nospecialize(it::$ValRef), i::Integer) = getfield(it, convert(Int, i), Base.@_boundscheck)

    function iterate(@nospecialize(t::$ValRef), i::Int=1)
        @inline
        return i==1 ? (t[i], i + 1) : nothing
    end

    get(t::$ValRef, i::Integer, default) = i == 1 ? getindex(t, i) : default
    get(f::Base.Callable, t::$ValRef, i::Integer) = i == 1 ? getindex(t, i) : f()

end)


