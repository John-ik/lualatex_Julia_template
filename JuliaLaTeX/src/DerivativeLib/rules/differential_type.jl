
@all_arg_constructor struct Differential
    var::Symbol
end
Core.eval(Base, quote

    length(@nospecialize(it::$Differential)) = 1
    size(@nospecialize(t::$Differential), d::Integer) = 1
    axes(@nospecialize(t::$Differential)) = (OneTo(1),)

    firstindex(@nospecialize(it::$Differential)) = 1
    lastindex(@nospecialize(it::$Differential)) = 1
    getindex(@nospecialize(it::$Differential), i::Int) = getfield(it, i, Base.@_boundscheck)
    getindex(@nospecialize(it::$Differential), i::Integer) = getfield(it, convert(Int, i), Base.@_boundscheck)
    getindex(@nospecialize(it::$Differential), i::Integer) = getfield(it, convert(Int, i), Base.@_boundscheck)

    function iterate(@nospecialize(t::$Differential), i::Int = 1)
        @inline
        return i == 1 ? (t[i], i + 1) : nothing
    end

    get(t::$Differential, i::Integer, default) = i == 1 ? getindex(t, i) : default
    get(f::Base.Callable, t::$Differential, i::Integer) = i == 1 ? getindex(t, i) : f()
end)
