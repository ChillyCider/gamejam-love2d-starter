-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class com.Pos
---@field x number
---@field y number
local Pos = {comName="pos"}
local MT = {__index=Pos}

local function constructor(x, y)
    return setmetatable({
        x=x or 0,
        y=y or 0,
    }, MT)
end

---@overload fun(x:number?, y:number?):com.Pos
return setmetatable(Pos, {__call=function(t, ...)
    return constructor(...)
end})
