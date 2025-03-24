
cases={}

local utf8e=unicode.utf8;
---@param str string
---@param j? integer symbol index
function cases.titleFirstWord(str,j)
    return utf8e.upper(
        utf8e.sub(str, 1, 1)
    )..utf8e.sub(str, 2,j)
end

---@param str string
---@param j? integer symbol index
function cases.lowerFirstWord(str,j)
    return utf8e.lower(
        utf8e.sub(str, 1, 1)
    )..utf8e.sub(str, 2,j)
end