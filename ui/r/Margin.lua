-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local Widget = require "ui.r.Widget"

---@class ui.r.Margin: ui.r.Widget
---@field topMargin number
---@field rightMargin number
---@field bottomMargin number
---@field leftMargin number
---@field child ui.r.Widget?
---@overload fun(topMargin:number?, rightMargin:number?, bottomMargin:number?, leftMargin:number?, child:ui.r.Widget?):ui.r.Margin
local Margin = {}
local MT = {__index=Margin}

---@param topMargin number?
---@param rightMargin number?
---@param bottomMargin number?
---@param leftMargin number?
---@param child ui.r.Widget?
function Margin:initialize(topMargin, rightMargin, bottomMargin, leftMargin, child)
    Widget.initialize(self)
    self.topMargin = topMargin or 0
    self.rightMargin = rightMargin or 0
    self.bottomMargin = bottomMargin or 0
    self.leftMargin = leftMargin or 0
    self.child = child
end

---@return number
function Margin:minWidth()
    if self.minWidthOverride then
        return self.minWidthOverride
    end

    if self.child then
        return self.leftMargin + self.child:minWidth() + self.rightMargin
    end

    return self.leftMargin + self.rightMargin
end

---@return number
function Margin:minHeight()
    if self.minHeightOverride then
        return self.minHeightOverride
    end

    if self.child then
        return self.topMargin + self.child:minHeight() + self.bottomMargin
    end

    return self.topMargin + self.bottomMargin
end

---@param x number
---@param y number
---@param width number
---@param height number
function Margin:layout(x, y, width, height)
    if self.child then
        self.child:layout(
            x + self.leftMargin,
            y + self.topMargin,
            x + width - self.leftMargin - self.rightMargin,
            y + height - self.topMargin - self.bottomMargin
        )
    end
end

function Margin:draw()
    if self.child then
        self.child:draw()
    end
end

---@diagnostic disable-next-line: param-type-mismatch
return setmetatable(Margin, {__index=Widget, __call=function(_, ...)
    local obj = setmetatable({}, MT)
    obj:initialize(...)
    return obj
end})
