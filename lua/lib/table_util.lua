
local function deep_copy_0(v)
    local t = type(v)
    if t~="table" then
        -- userdata.... IDK how to handle this
        return v
    end
    return table.deepcopy(v)
end

---@generic T:table
---@param self T
---@return T
function table.deepcopy(self)
    local it={}
    for key, value in pairs(self) do
        it[key]=deep_copy_0(value)
    end
    return it
end