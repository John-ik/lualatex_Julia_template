module DependencyInstaller


import Pkg


allModules::Vector{String} = []
macro ___collectPkg(func::Expr)
    @assert func.head == :function "Expected function expr by found" * string(func.head)
    local body::Expr = func.args[2]
    @assert body.head == :block "Unexpected body head" * string(body.head)




    local collectModules(name::String) = push!(allModules, name)
    local collectModules(names::Vector{String}) = names .|> collectModules
    local collectModules(names::Tuple{String}) = names .|> collectModules

    local function processExpr(expr) end;
    local function processExpr(expr::Expr)
        #TODO visitor
        (expr.head != :call || typeof(expr.args[1])!=Expr || expr.args[1].head != :. || expr.args[1].args[1] != :Pkg || expr.args[1].args[2].value != :add) && return
        collectModules(eval(expr.args[2]))
    end
    body.args .|> processExpr
    return func
end

@___collectPkg function run()
    # Pkg.add(url="https://github.com/John-ik/lualatex_Julia_template", subdir="JuliaLaTeX")
    Pkg.add(["LaTeXStrings", "Unitful", "UnitfulLatexify", "Latexify", "LaTeXDatax"])
    Pkg.add("DataFrames")
    Pkg.add("CSV")



    
    mkpath(dirname(DEPENDENCY_CHECK_FILE))
    open(DEPENDENCY_CHECK_FILE, "w") do f
        for m in allModules
            println(f, m)
        end
    end
end



const DEPENDENCY_CHECK_FILE = "gitignore/has_dependency"

function validDependencies()
    !isfile(DEPENDENCY_CHECK_FILE) && return false
    
    local set=Set(allModules)
    for line in readlines(DEPENDENCY_CHECK_FILE)
        delete!(set,strip(line))
    end

    length(set)==0
end

function initDependencies()
    validDependencies() && return
    run()
end

if @isdefined __init__
    println("Module", Base.function_module(__init__))
end
function main()
    # run()
    validDependencies()
end

(abspath(PROGRAM_FILE) == @__FILE__) && main()





end
