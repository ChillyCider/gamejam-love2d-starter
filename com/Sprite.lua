-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class com.Sprite
---@field image love.Image?
local Sprite = {comName="sprite"}
local MT = {__index=Sprite}

local function constructor(image)
    return setmetatable({
        image=image,
    }, MT)
end

---@overload fun(image:love.Image?):com.Sprite
return setmetatable(Sprite, {__call=function(t, ...)
    return constructor(...)
end})
