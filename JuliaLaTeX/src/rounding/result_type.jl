struct RoundResult
    m1::Int
    m2::Int
    m3::Int
    e10::Int
    unit::Union{Nothing,Unitful.Unitlike}
end
@save_exported export RoundResult


int_head(result::RoundResult) = result.m1 * 100 + result.m2 * 10 + result.m3
Tuple(r::RoundResult) = (r.m1, r.m2, r.m3, r.e10, r.unit)
tail_size(result::RoundResult) = @switch (result.m1 + result.m2 * 10 + result.m3 * 100) => {
    _ < 10 => 1;
    _ < 100 => 2;
    _ => 3;
}
Base.show(io::IO, res::RoundResult) = begin
    print(io, res.m1, ".", res.m2)
    res.m3 != 0 && print(io, res.m3)
    print(io, " * ", 10, '^', res.e10)
    res.unit === nothing && return
    print(io, " * ", res.unit)
end

function Base.float(res::RoundResult)
    x = (res.m1 * 100 + res.m2 * 10 + res.m3) * 10.0^(res.e10 - 2)
    res.unit !== nothing && return x * res.unit
    x
end
