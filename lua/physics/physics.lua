---@diagnostic disable: undefined-doc-name
require 'lua.physics.load_symmath'
-----------------------------------------------------------
-- LaTeX command:
local printConstsCmd = 'printconsts' -- For print all consts from your file
local printFormulasCmd = 'printformulas' -- For print formulas and their description
local symbolCmd = 'symbolof'
local unitCmd = 'unitof'
local calcCmd = 'evalof'
local equationCmd = 'equationof'
local constCmd = 'constof'
local resultCmd = 'resultof'

local formulasTable = 'Formulas'

local formulaErrText = 'систематическая погрешность'
local formulaErrLabel = 'theta'

SavesResult = {}
-----------------------------------------------------------
require('lua.trig')
require('lua.physics.metric')
lrequire 'rounding'



function toRad(degree)
    return degree * math.pi / 180
end

function toDeg(radian)
    return radian * 180 / math.pi
end


--- Export to LaTeX using symmath, but with custom open and close symbols
---@param expr any
---@param open string
---@param close string
---@param options table<string, bool>
---@return string
function toMathWith(expr, open, close, options)
    local m = symmath.export.LaTeX
    local save_open, save_close = m.openSymbol, m.closeSymbol
    m.openSymbol, m.closeSymbol = open, close

    if options then 
        for k, v in pairs(options) do _G[k] = v end
    end

    local str = symmath.tostring(expr)

    if options then
        for k, v in pairs(options) do _G[k] = nil end
    end

    m.openSymbol, m.closeSymbol = save_open, save_close
    return str
end

function toInlineMath(expr, option)
    return toMathWith(expr, '\\(', '\\)', option)
end

function toBigMath(expr, option)
    return toMathWith(expr, '\\[', '\\]', option)
end

function toRawMath(expr, option)
    return toMathWith(expr, '', '', option)
end

function toResult(value, theta)
    local value, theta = rounding.asTheta(value, theta)
    local exp = math.floor(math.log(value, 10))
    value = value * 10^(-exp)
    theta = theta * 10^(-exp)
    return string.format('{(%s \\pm %s) \\cdot 10^{%s}}', value, theta, exp)
end

---@param expr Const
---@param open ?string
---@param close ?string
local function ConstNameToMath(expr, open, close)
    local m = symmath.export.LaTeX
    local save_open, save_close = m.openSymbol, m.closeSymbol
    m.openSymbol, m.closeSymbol = open or '', close or ''
    local str = expr:tostringNamed()
    m.openSymbol, m.closeSymbol = save_open, save_close
    return str
end


-- --------------------------------------------------------
local formulaFieldsRequested = {"label", "text", "symbol", "f", "vars"}

function FormulaTheta(formula, theta_expr)
    for _, field in ipairs(formulaFieldsRequested) do
        if not formula[field] then error("No ["..field.."] in formula ["..i.."]") end
    end

    local formulaErr = {}
    formulaErr.label = formula.label..formulaErrLabel
    formulaErr.text  = formulaErrText.." "..cases.lowerFirstWord(formula.text)
    formulaErr.symbol= 'Theta_{'..formula.symbol..'}'
    formulaErr.vars  = formula.vars
    formulaErr.where = {
        var(formula.symbol):eq(formula.f)
    }
    formulaErr.f     = theta_expr
    formulaErr.round = rounding.theta
    formulaErr.mark_theta = true

    print("FormulaTheta", formulaErr.where[1])

    return formulaErr
end


function ExprSubst(expr, vars)
    if vars then
        for k,v in pairs(vars) do
            if type(k) == 'string' then k = symmath.var(k) end
            -- clone so we can handle numbers and variable constants
            expr = expr:replace(k, symmath.clone(v))
        end
    end
    
    return toRawMath(expr)
end

function FormulaSubst(formula)
    expr = formula.f:clone()
    if formula.where then
        for _, eqn in ipairs(formula.where) do
            expr = expr:subst(eqn)
        end
    end
    return expr
end

local digit2word = {
    ['1'] = 'one',
    ['2'] = 'two',
    ['3'] = 'three',
    ['4'] = 'four',
    ['5'] = 'five',
    ['6'] = 'six',
    ['7'] = 'seven',
    ['8'] = 'eight',
    ['9'] = 'nine',
    ['0'] = 'zero'
}

---Prepare label string to LaTeX command
---@param label string
---@return string
local function prepareLabel(label)
    label = string.gsub(label, '_', '')
    label = string.lower(label)
    for dig, word in pairs(digit2word) do
        label = string.gsub(label, dig, word)
    end
    return label
end

local function printConsts(consts)
    local str = ""
    for key, t in pairs(consts) do
        dprint(key, t , (next(consts, key) and ', ' or '.'))
        if not t.hide then
            str = str ..
                (t.text or "!!!NO TEXT!!!") ..
                ' $' ..
                ConstNameToMath(t) .. ' = ' .. toRawMath(t) ..
                '$' ..
                ', '
        end
        -- Command to get Value of 
        tex.print('\\newcommand{\\'..constCmd..prepareLabel(key)..'}{'..toRawMath(t)..'}')
    end
    dprint("<<"..str..">>")
    dprint(j, unicode.grapheme.find(str, '%.[^%w]*%, $'))
    if unicode.grapheme.find(str, '%.[^%w]*%, $') then
        str = unicode.grapheme.sub(str, 1, -3)
    else
        str = unicode.grapheme.sub(str, 1, -3) .. "."
    end
    dprint("<<"..str..">>")
    tex.print(cases.titleFirstWord(str))
end



local function printFormulas(formulas, consts)
    local ff = unicode.utf8.format

    local exist = {}
    for i, formula in ipairs(formulas) do
        for _, field in ipairs(formulaFieldsRequested) do
            if not formula[field] then error("No ["..field.."] in formula ["..i.."]") end
        end
        exist[formula.label] = true
    end
    texio.write('term and log', 'PRINT_FORMULAS exist = ', stringify(exist), '\n')

    local str = ""
    for i, formula in ipairs(formulas) do
        for _, field in ipairs(formulaFieldsRequested) do
            if not formula[field] then error("No ["..field.."] in formula ["..i.."]") end
        end

        
        formula.unit = formula.unit or JUST
        formula.round = formula.round or  rounding.to3digitScience

        formula.symbol = symmath.export.LaTeX:fixVariableName(formula.symbol)
        
        ConstShouldBeNamed = true
        
        local label = formula.label
        
        formulas[label] = {}
        local formulaInG = formulas[label]
        local formulaInG_tex = ff("%s['%s']", formulasTable, label)
        formulaInG.eval = function (params)
            return formula.round(formula.f:eval(params))
        end
        formulaInG.equation = function (params)
            SavesResult[params] = formulaInG.eval(params)
            return ff("\\[ %s = %s \\approx %s \\: \\unitof%s \\]",
                toRawMath(formula.symbol), toRawMath(ExprSubst(formula.f, params)), toRawMath(formulaInG.eval(params)), label)
        end
        formulaInG.evalwiththeta = function (params)
            local theta = formulas[label..formulaErrLabel].eval(params)
            local val = formulaInG.eval(params)
            val, theta = rounding.asTheta(val, theta)
            return toResult(val, theta)
        end

        tex.sprint(cases.titleFirstWord(formula.text), ":")
        tex.print('\\begin{equation}')
            tex.print(ff('%s = %s', formula.symbol, toRawMath(formula.f)))
            tex.print(ff('\\label{formula:%s}', label))
        tex.print('\\end{equation}')

        -- command for unit
        tex.print('\\newcommand{\\'..unitCmd..label..'}{\\text{'..tostring(formula.unit)..'}}')

        -- command for eval
        tex.print('\\newcommand{\\'..calcCmd..label..'}[1]{\\directlua{')
            tex.print('tex.print(toRawMath('..formulaInG_tex..'.eval(#1)))')
        tex.print('}}')

        -- command for eval with theta
        if (not formula.mark_theta) and exist[label..formulaErrLabel] then
            tex.print('\\newcommand{\\'..resultCmd..label..'}[1]{\\directlua{')
                tex.print('tex.print(toRawMath('..formulaInG_tex..'.evalwiththeta(#1)))')
            tex.print('}}')
        end

        -- command for equation
        tex.print('\\newcommand{\\'..equationCmd..label..'}[1]{\\directlua{')
            tex.print('tex.print('..formulaInG_tex..'.equation(#1))')
        tex.print('}}')

        -- command for symbol of formula 
        tex.print('\\newcommand{\\'..symbolCmd..label..'}{'..formula.symbol..'}')

        -- Description
        -- next - check table for key-value exists
        local dependentVars = formula.f:getDependentVars()
        if next(formula.vars) and #dependentVars > 0 then
            str = "где "
            for i, dependent in ipairs(dependentVars) do
                local varDesc = formula.vars[dependent.name]
                if varDesc then
                    str = str .. toInlineMath(dependent) .. " --- " .. varDesc 
                        .. (i == #dependentVars and "." or ", ")
                end
            end
        end
        tex.print(str); str = ""

        tex.print('\\par')
        ConstShouldBeNamed = false

        formula.f = FormulaSubst(formula)
    end
end


define_latex_command(printConstsCmd, function ()
    printConsts(Consts)
end)

define_latex_command(printFormulasCmd, function ()
    printFormulas(Formulas, Consts)
end)

print("-----", debug.getinfo(function () end, "S").source:sub(2), "-----")
print(toBigMath((Kilo.JUST(1) * JUST(10) ^ JUST(-9)):eval()))
print(Value(1, JUST) < 2)
print(Value(1, JUST) > 0)
print(Value(1, JUST) == Constant(1)) -- Lua (table == number) -> always false

print(prepareLabel('label_l_LW_ll_0_66'))

print(toInlineMath(2.0))
print("------ ROUNDING -----")
for _, v in ipairs({4.3e10, 4.3e-9, 4.2e99, 4.26e99, 3.55449, 11.7, 0.023, 0.086,
        0.6666, 21.33, 8.1, 0.333, 0.287}) do
    print(v, "THETA", rounding.theta(v), "| to3digit", rounding.to3digitScience(v))
end
print("----- END -----")
