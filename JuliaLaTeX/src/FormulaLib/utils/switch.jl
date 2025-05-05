module SwitchMacroUtils
export @switch

try_replace(expression::Symbol, replaced::Base.RefValue{Bool}, compare_name::Symbol) =
    expression == :_ ? (replaced.x = true; compare_name) : expression
for idt in [Number, String, QuoteNode]
    Core.eval(@__MODULE__, quote
        try_replace(expression::$idt, replaced::Base.RefValue{Bool}, compare_name::Symbol) =
            expression
    end)
end
try_replace(expression::Expr, replaced::Base.RefValue{Bool}, compare_name::Symbol) =
    Expr(expression.head, map(x -> try_replace(x, replaced, compare_name), expression.args)...)

cached_expr_symbol::Symbol = :___value___



"""
    @switch EXPR => {
        EXPR => EXPR;
        EXPR => EXPR;
    }
Adds switch expression

# Examples

### Example 1
```
@switch typeof(reference) => {
    _ <: Vector => println(Vector);
    _ <: Tuple => println(Tuple);
    _ => println(Missing);
}
```
#### Transformed to
```
local ___value___ = typeof(reference)
if ___value___ <: Vector
    println(Vector)
elseif ___value___ <: Tuple
    println(Tuple)
else
    println(Missing)
end
```

### Example 2
```
@switch object => {
    typeof(_) <: Vector => println(Vector);
    3 => println("Number: ",'3');
    _ => println("Other");
}
```
#### Transformed to
```
local ___value___ = object
if typeof(___value___) <: Vector
    println(Vector)
elseif ___value___ == 3
    println("Number: ", '3')
else
    println("Other")
end
```

"""
macro switch(expr)
    @assert expr.head == :call
    @assert expr.args[1] == :(=>)
    value = expr.args[2]


    body::Expr = expr.args[3]::Expr

    prevSum::Expr = Expr(:block,
        __source__,
        Base.remove_linenums!(:(local $cached_expr_symbol = $value)),
    )
    startBody::Expr = prevSum
    ifSym::Symbol = :if
    # println(string(expr))
    boolRef::Base.RefValue = Ref(false)
    for arg in body.args
        @assert typeof(arg) == Expr LazyString("arg = ",arg)
        arg.head == :parameters && continue
        @assert arg.args[1] == :(=>) string("expected '=>', but found '",arg.args[1],"' in expr '",arg,"'")
        match_expression = arg.args[2]

        ifStmt = if match_expression == :_
            Expr(:block, arg.args[3])
        else
            boolRef.x = false
            match_expression = try_replace(match_expression, boolRef, cached_expr_symbol)
            if boolRef.x
                Expr(ifSym, match_expression, arg.args[3])
            else
                Expr(ifSym, Expr(:call, :(==), cached_expr_symbol, match_expression), arg.args[3])
            end
        end

        push!(prevSum.args, ifStmt)
        prevSum = ifStmt
        ifSym = :elseif
    end

    # Expr(:block,startBody)|>Base.remove_linenums! |> string|>println
    return esc(Expr(:block, startBody))

end

macro using_self(expr)
    return esc(Expr(:block,
        Expr(:(=), Symbol("@switch"), var"@switch"),
        :(),
    ))
end

end

SwitchMacroUtils.@using_self(using .SwitchMacroUtils)
