

let supported_int = Iterators.flatten((Base.BitInteger_types, [BigInt]))
    for target in supported_int
        target_name = Symbol(target.name.name)
        eval(quote
            function Base.$target_name(x::ExponentNumber{$target_name})
                exp = real_exponent(x)
                if exp < 0
                    throw(InexactError($(Expr(:quote, target.name.name)), $target, x))
                end
                return x.int_value * $(target(10))^exp
            end
        end)
        for source in supported_int
            (source==target) && continue
            source_name = Symbol(source.name.name)
            eval(quote
                function Base.$target_name(x::ExponentNumber{$source_name})
                    return $target_name($source_name(x))
                end
            end)
        end
    end
end

