# VS Code


# LuaLaTeX

## Params guap package

- dataxfile — pass as datax file in datax package
- distinctpath — use as prefix in `\distinctinput`: `\distinctinput{file}` inputs `distinctpath/file`

## BUGS:

No using `_` in distinctpath: `no_allowed_dir`, `allowed-dir`. But using `_` in filenames in the dir allowed: `allowed-dir/allowed_table.tex`

Why: underscore is special character, filename `detokenize`, but dir no. Solution exist but not realized.

# Julia
## Dependency for out of this template
julia> `] add https://github.com/John-ik/lualatex_Julia_template:JuliaLaTeX`

или `import Pkg; Pkg.add(url="https://github.com/John-ik/lualatex_Julia_template", subdir="JuliaLaTeX")`