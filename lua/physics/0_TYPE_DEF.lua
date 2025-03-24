

---@class ToMath
---@field toMath fun():string
---
---@class ToText
---@field toText fun():string
---
---@class Labeled
---@field label string
---
---@class WithText
---@field text string




---@class Value
---@field value string
---
---@class Unit
---@field unit string

---@class Constant:Labeled,WithText
---@field label string
---@field text string
---@field val? MetricValue
---@field hide? boolean




---@class FormulaVar:Labeled,WithText

---@class Formula:Labeled,WithText
---@field f string
---@field symbol string
---@field vars (FormulaVar|string)[]
---@field unit string
---@field format "x1"|"x2"|"x3"
---@field where? table<string,string>

