---@class Pos
---@field x number
---@field y number
local Pos = {comName="pos", comTypeName="Pos"}
local PosMT = {__index=Pos}

local function constructor(x, y)
    return setmetatable({
        x=x or 0,
        y=y or 0,
    }, PosMT)
end

---@overload fun(x:number?, y:number?):Pos
return setmetatable(Pos, {__call=function(t, ...)
    return constructor(...)
end})
