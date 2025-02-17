---@class Sprite
---@field image love.Image?
local Sprite = {comName="sprite"}
local SpriteMT = {__index=Sprite}

local function constructor(image)
    return setmetatable({
        image=image,
    }, SpriteMT)
end

---@overload fun(image:love.Image?):Sprite
return setmetatable(Sprite, {__call=function(t, ...)
    return constructor(...)
end})
