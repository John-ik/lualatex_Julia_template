

function define_latex_command(function_name, lua_function)
    local arg_count = debug.getinfo(lua_function, "u").nparams
    -- _G[function_name] = lua_function
    local i = 1000;
    local t=lua.get_functions_table()
    while true do
        if t[i] == nil then
            break
        end
        i = i + 1
    end
    t[i]=function ()
        local args={}
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


--[[ 
if define_my_command_meta_data==nil then
    _G["define_my_command_meta_data"]={}
end 

function define_my_command(function_name, lua_function)
    local arg_count = debug.getinfo(lua_function, "u").nparams
    _G[function_name] = lua_function
    local i = 1000;
    local t=lua.bytecode
    while true do
        if lua.bytecode[i] == nil then
            break
        end
        i = i + 1
    end
    define_my_command_meta_data[i]={
        lua_function,
        arg_count,
    }
    lua.bytecode[i]=function (s)
        local args={}
        local i=1;
        print("s.."..s)
        local lua_function,arg_count=table.unpack(define_my_command_meta_data[s])
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
        "\\luabytecodecall" .. i .. "{" ..
        table.concat(argRef,"}{") .. "}}"
    -- tex.print(stri.."")
    print("\n v__",stri,"\n")
    return lua_function
end ]]