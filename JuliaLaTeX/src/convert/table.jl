

#= 
function data_to_LaTeX_table(data::DataFrame)
    io = IOContext(IOBuffer())
    data_to_LaTeX_table(io, data)
    return String(take!(io.io))
end =#

function data_to_LaTeX_table(filename::String, data::Union{DataFrame, Calculation}, @nospecialize(nameAliases::Pair...); permissions::String = "w")
    mkpath(dirname(filename))
    open(filename, permissions) do io
        return data_to_LaTeX_table(io, data, nameAliases...)
    end
end

function data_to_LaTeX_table(io::IO, data::DataFrame, @nospecialize(nameAliases::Pair...))
    set_default(unitformat = :siunitx, fmt = FancyNumberFormatter(4))
    nameAliases = Dict(nameAliases...)
    # @show
    local ret = pretty_table(io,
        [LatexCell(latexify(
            if typeof(v) == Evaluatable
                UnitSystem.extract_value(
                    UnitSystem.applyUnitTo(Core.eval(eval_module(), v.inlineWithUnits), v.unit),
                )
            else
                UnitSystem.extract_value(v)
            end,
        )) for v in Tables.matrix(data)]
        ; backend = Val(:latex), alignment = :c, vlines = :all,
        header = [
            string(raw"$",
                latexify(get(nameAliases, name, name); env = :raw),
                ",\\;",
                if typeof(u) == Evaluatable
                    # UnitSystem.applyUnitTo(u.inlineWithUnits |> eval,u.unit)
                    latexify(u.unit)
                else
                    latexify(UnitSystem.extract_unit(u))
                end,
                raw"$")
            for (name, u) in zip(names(data), data[1, :])
        ] .|> LatexCell,
    )
    reset_default()
    return ret
end



function data_to_LaTeX_table(io::IO, data::Calculation, @nospecialize(nameAliases::Pair...))
    set_default(unitformat = :siunitx, fmt = FancyNumberFormatter(4))
    nameAliases = Dict(nameAliases...)
    # @show
    local ret = pretty_table(io,
        hcat((map(
            LatexCell ∘ latexify ∘ UnitSystem.extract_value ∘ eval_with_units,
            isa(v_list, Vector) ? v_list : [v_list])
              for (_, v_list) in data)...)
        ; backend = Val(:latex), alignment = :c, vlines = :all,
        header = [
            string(raw"$",
                latexify(get(nameAliases, string(name), name); env = :raw),
                ",\\;",
                begin
                    list_type = typeof(u_list)
                    # @assert list_type <: AbstractVector LazyString("column must be represented as Vector but found '", list_type, "'")
                    first_elem, elem_type = if list_type <: AbstractArray
                        u_list[1], eltype(u_list)
                    else
                        u_list, list_type
                    end
                    has_nothing = false
                    if list_type <: AbstractArray
                        @label try_again
                        if isa(elem_type, Union)
                            if elem_type.a === Nothing
                                has_nothing = true
                                elem_type = elem_type.b
                                @goto try_again
                            elseif elem_type.b === Nothing
                                has_nothing = true
                                elem_type = elem_type.a
                                @goto try_again
                            else
                            end
                        end
                        if has_nothing
                            i = 1
                            while first_elem === nothing
                                first_elem = u_list[i]
                                i += 1
                            end
                        end
                    end
                    # @show elem_type
                    # if elem_type==Any && list_type<:AbstractArray
                    #     elem_type=promote_type((typeof(x) for x in u_list)...)
                    #     @show (2,elem_type)
                    # end
                    if elem_type <: Evaluatable
                        latexify(first_elem.unit)
                    elseif elem_type <: Unitful.AbstractQuantity
                        latexify(UnitSystem.extract_unit(elem_type))
                    elseif elem_type <: Unitful.Unitlike
                        latexify(elem_type.instance())
                    else
                        latexify(UnitSystem.extract_unit(first_elem))
                    end
                end,
                raw"$") |> LatexCell
            for (name, u_list) in data],
    )
    reset_default()
    return ret
end