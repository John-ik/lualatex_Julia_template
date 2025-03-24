
if define_my_command_meta_data==nil then
    _G["define_my_command_meta_data"]={}
end 

function define_my_command(function_name, lua_function)
    local arg_count = debug.getinfo(lua_function, "u").nparams
    _G[function_name] = lua_function
    local i = 1;
    print("----- .."..arg_count)
    local t=lua.get_functions_table()
    while true do
        if t[i] == nil then
            break
        end
        i = i + 1
    end
    define_my_command_meta_data[i]={
        lua_function,
        arg_count,
    }
    t[i]=function ()
        local args={}
        local i=1;
        -- local lua_function,arg_count=table.unpack(define_my_command_meta_data[s])
        for i = 1, arg_count do
            local arg=token.scan_string()
            table.insert(args,arg)
        end
        lua_function(table.unpack(args))
    end;

    local argRef={}
    for i = 1, arg_count do
        argRef[i]="#"..i
    end
    
    local stri = "\\newcommand{\\" .. function_name .. "}[" .. tostring(arg_count) .. "]{" ..
        "\\luafunction" .. i .. "{" ..
        table.concat(argRef,"}{") .. "}}"
    tex.print(stri.."")
    
    print("v___", stri)
    return lua_function
end

define_my_command("ifmany", function(a,b,c)
    print("If many")
    if a then a=a else a="n" end
    if b then b=b else b="n" end
    if c then c=c else c="n" end

    -- tex.print(tostring(a).."\\"..tostring(b)..'\\'..tostring(c))
    tex.print("Hello world 4 '"..a.."', '"..b.."', '"..c.."'")
end
)
