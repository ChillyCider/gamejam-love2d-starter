-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local Widget = require "ui.r.Widget"

---@class ui.r.Label: ui.r.Widget
---@field font love.Font
---@field text string
---@field textAlign love.AlignMode
---@field x number
---@field y number
---@field width number
---@field height number
---@overload fun(font:love.Font, text:string, textAlign:love.AlignMode?):ui.r.Label
local Label = {}
local MT = {__index=Label}

---@param text string
---@param textAlign love.AlignMode
function Label:initialize(font, text, textAlign)
    Widget.initialize(self)
    self.font = font
    self.text = text
    self.textAlign = textAlign
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
end

---@return number
function Label:minWidth()
    if self.minWidthOverride then
        return self.minWidthOverride
    end

    return self.font:getWidth(self.text)
end

---@return number
function Label:minHeight()
    if self.minHeightOverride then
        return self.minHeightOverride
    end

    return self.font:getHeight()
end

---@param x number
---@param y number
---@param width number
---@param height number
function Label:layout(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

function Label:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(self.text, self.x, self.y, self.width, self.textAlign)
end

---@diagnostic disable-next-line: param-type-mismatch
return setmetatable(Label, {__index=Widget, __call=function(_, ...)
    local obj = setmetatable({}, MT)
    obj:initialize(...)
    return obj
end})
