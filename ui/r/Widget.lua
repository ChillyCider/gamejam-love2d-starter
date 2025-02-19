-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class ui.r.Widget
---@field minWidthOverride number?
---@field minHeightOverride number?
---@overload fun():ui.r.Widget
local Widget = {}
local MT = {__index=Widget}

function Widget:initialize()
    self.minWidthOverride = nil
    self.minHeightOverride = nil
end

---@return number
function Widget:minWidth()
    return self.minWidthOverride or 0
end

---@return number
function Widget:minHeight()
    return self.minHeightOverride or 0
end

---@param x number
---@param y number
---@param width number
---@param height number
---@diagnostic disable-next-line: unused-local
function Widget:layout(x, y, width, height)
end

function Widget:draw()
end

---@diagnostic disable-next-line: param-type-mismatch
return setmetatable(Widget, {__call=function(_, ...)
    local obj = setmetatable({}, MT)
    ---@diagnostic disable-next-line: redundant-parameter
    obj:initialize(...)
    return obj
end})
