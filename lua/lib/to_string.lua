---@param it any
---@param oneline? boolean
---@param index? number
---@param visited? table<any,integer>
---@return string
function stringify(it, oneline, index, visited)
    local t = type(it);
    if (t == "table") then
        return stringTable(it, oneline, index or 0, visited or { n = 0 })
    elseif t == "string" then
        ---@type string
        local it = it;
        return '"' .. it:gsub("[\"\\]", "\\%0") .. '"'
    end

    return tostring(it)
end

function pprint(it)
    print(stringify(it, false))
end

local stringify0 = stringify
_G.stringify = {
    indentSymbol = "  "
}
setmetatable(stringify, {
    __call = function(self, ...)
        return stringify0(...)
    end
})

---@param it table
---@param oneline? boolean
---@param i number
---@param visited table<any,integer>
function stringTable(it, oneline, i, visited)
    local id = visited[it]

    if id ~= nil then
        --  "[cyclic reference]"
        return "[cyclic reference " .. tostring(id) .. "]"
    end
    local count = visited.n;
    visited[it] = count
    visited.n = count + 1
    local indentSymbol = stringify.indentSymbol;
    local indent = indentSymbol:rep(i + 1)
    local newLineIndent;
    if (oneline) then
        newLineIndent = ' '
    else
        newLineIndent = '\n' .. indent
    end
    local buffer = "{";
    for key, value in pairs(it) do
        buffer =
            buffer .. newLineIndent ..
            stringify(key, true, nil, visited) .. ' = ' .. stringify(value, oneline, i + 1, visited) .. ';'
        ;
    end
    if (oneline) then
        buffer = buffer .. "}"
    else
        buffer = buffer .. "\n" .. indentSymbol:rep(i) .. "}"
    end
    return buffer;
end
