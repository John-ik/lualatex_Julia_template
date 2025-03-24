
local myPath = debug.getinfo(function () end, "S").source:sub(2):gsub('init.lua', '');

local function load(it)
    return loadfile(myPath .. it)
end
local function req(it)
    require(myPath .. it)
end

req("to_string.lua")
req("table_util.lua")
req("string_util.lua")
req("unicode_data_load.lua")
req("unicode_util.lua")
req("localload.lua")
req("cases.lua")


function dummy(...)end
function dprint(...)
    
end