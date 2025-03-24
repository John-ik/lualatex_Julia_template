local function parse_ucd_txt(filepath)
    local ucd_data = {}

    local file = io.open(filepath, "r")
    if not file then
        error("Could not open file: " .. filepath)
    end

    for line in file:lines() do
        -- Removing comments and empty lines
        local comment_start = line:find("#")
        if comment_start then
            line = line:sub(1, comment_start - 1)
        end
        line = line:match("^%s*(.-)%s*$") -- removing spaces
        if not line or line == "" then
            goto continue
        end


        local codepoint_hex, char_name, other_fields = line:match("([0-9A-F]+);%s*([^;]+);(.*)")

        if codepoint_hex then
            local codepoint = tonumber(codepoint_hex, 16)

            ucd_data[codepoint] = {
                name = char_name,
                fields = {}
            }
            local fields=ucd_data[codepoint].fields
            for field in line:gmatch("([^;]*);") do
                table.insert(fields, field:match("^%s*(.-)%s*$")) -- Убираем начальные/конечные пробелы
            end
        else
            
            --  print("Skipping line:", line)
        end

        ::continue::
    end

    file:close()
    return ucd_data
end


utf8.ucd = parse_ucd_txt("UnicodeData.txt") -- Замените на путь к вашему файлу
