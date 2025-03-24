--@class utf8
-- utf8 = {}


---@param char_data integer|string|table
---@param index? integer
function utf8.is_uppercase(char_data, index)
    if type(char_data) ~= "table" then
        return utf8.is_uppercase(utf8.chardata(char_data, index))
    end
    return char_data.fields[3] == "Lu" -- Проверяем General_Category
end

---@param char_data integer|string|table
---@param index? integer
function utf8.is_lowercase(char_data, index)
    if type(char_data) ~= "table" then
        return utf8.is_lowercase(utf8.chardata(char_data, index))
    end
    return char_data.fields[3] == "Ll" -- Проверяем General_Category
end

---@param charOrCodepoint integer|string
---@param index? integer
function utf8.chardata(charOrCodepoint, index)
    if (type(charOrCodepoint) == "string") then
        return utf8.chardata(utf8.codepoint(charOrCodepoint, index or 1))
    end
    return utf8.ucd[charOrCodepoint]
end



---@param codepoint integer
---@param char_data table
---@param fieldIdx integer
---@return integer
function utf8.swapcase(codepoint,char_data,fieldIdx)
    local mapping = char_data.fields[fieldIdx]
    if mapping and mapping ~= "" then
        if tonumber(mapping, 16)==nil then
            print("mapping: ", stringify(char_data))
        end
        return tonumber(mapping, 16)
    end
    return codepoint
end

---@param codepoint integer
---@return integer
function utf8.to_lowercase(codepoint)
    local char_data = utf8.ucd[codepoint]
    if char_data==nil then
        return codepoint
    end
    return utf8.swapcase(codepoint,char_data,14)
end

---@param codepoint integer
---@return integer
function utf8.to_uppercase(codepoint)
    local char_data = utf8.ucd[codepoint]
    if char_data==nil then
        return codepoint
    end
    return utf8.swapcase(codepoint,char_data,13)
end

---@param string string
---@return string
function utf8.to_uppercase_string(string)
    local len = utf8.len(string);
    local buffer = {}
    local i = 1;
    for byteI, code in utf8.codes(string) do
        local upper = utf8.to_uppercase(code)
        -- print("I: " .. tostring(i) .. "(" .. tostring(code) .. ")" .. ": " .. stringify(upper))
        buffer[i] = utf8.char(upper)
        i = i + 1;
    end
    return table.concat(buffer)
end

---@param string string
---@return string
function utf8.to_lowercase_string(string)
    local len = utf8.len(string);
    local buffer = {}
    local i = 1;
    for byteI, code in utf8.codes(string) do
        local upper = utf8.to_lowercase(code)
        -- print("I: " .. tostring(i) .. "(" .. tostring(code) .. ")" .. ": " .. stringify(upper))
        buffer[i] = utf8.char(upper)
        i = i + 1;
    end
    return table.concat(buffer)
end

