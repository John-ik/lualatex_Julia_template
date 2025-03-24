print("INIT LOCALLOAD")


local function get_caller(offset)
    local info = debug.getinfo(1+offset, "Sl") -- 2 - уровень стека (1 - текущая функция, 2 - вызывающая)
    return info.short_src;
end

---@param f fun(name:string):any
---@param name string
---@param wrap boolean
local function invokeWithLocal(f, name)
    
    local curPath = {}
    for word in string.split_iter(get_caller(3),"/") do
        if word==".." then
            table.remove(curPath,#curPath)
        else
            table.insert(curPath,word)
        end
    end
    table.remove(curPath,#curPath)
    for word in string.split_iter(name,"/") do
        if word==".." then
            table.remove(curPath,#curPath)
        elseif word=='.' then
        else
            table.insert(curPath,word)
        end
    end
    -- print("PATH: "..table.concat(curPath,"/"))
    local val = f(table.concat(curPath,"/"))
    return val
end
---@param it string
---@return function|nil
function _ENV.lloadfile(it)
    return invokeWithLocal(function(name)
        return loadfile(name)
    end, it)
end

function _ENV.lrequire(it)
    invokeWithLocal(function(name)
        return require(name)
    end, it)
end

---@param anchor function
---@param print? boolean
function makeLocalLoading(anchor, print)
    if (anchor == nil) then
        error("Expected anchor object as first arg")
    end

    local myPath = debug.getinfo(anchor, "S").source:sub(2) .. "/../";
    if (print) then
        print("path: " .. myPath)
    end

    ---@alias LocalLoad fun(name:string):function
    ---@alias LocalRequire fun(name:string)

    ---@param it string
    ---@return function|nil
    local function loadLocal(it)
        return loadfile(myPath .. it)
    end
    ---@param it string
    local function requireLocal(it)
        require(myPath .. it)
    end
    return loadLocal, requireLocal
end
