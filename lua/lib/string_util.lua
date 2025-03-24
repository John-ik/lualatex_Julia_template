---@param str string
---@param sep string
---@return string[]
function string.split(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

---@param str string
---@param sep string
---@return fun():string|nil
function string.split_iter(str, sep)
    if sep == nil then sep = "%s" end
    
    local start = 1
    return function()
        if start then
            local i, j = string.find(str, "[^" .. sep .. "]+", start)
            if i then
                local word = string.sub(str, i, j)
                start = j + 1
                return word
            else
                ---@diagnostic disable-next-line: cast-local-type
                start = nil
            end
        end
    end
end
